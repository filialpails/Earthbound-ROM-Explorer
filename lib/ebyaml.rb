require 'yaml'
require_relative 'memoizable'
require_relative 'rom_file'

module EBYAML
  @yaml = File.open(Rails.configuration.yaml_location, 'r') do |file|
    YAML.load_stream(file.read, file.path)
  end
  @info = @yaml[0]
  @map = @yaml[1]

  class << self
    extend Memoizable

    attr_reader :info

    def rom_map
      _rom_map.map {|(_, block)| parse_block(block, full: false)}
    end
    memoize :rom_map

    def ram_map
      _ram_map.map {|(_, block)| parse_block(block, full: false)}
    end
    memoize :ram_map

    def [](id)
      parse_block(@map[id])
    end
    memoize :[]

    def rom_block_names
      rom_map.select {|block|
        !block.name.nil?
      }.map {|block|
        [block.offset, block.name]
      }.to_h
    end
    memoize :rom_block_names

    def ram_block_names
      ram_map.select {|block|
        !block.name.nil?
      }.map {|block|
        [block.offset, block.name]
      }.to_h
    end
    memoize :ram_block_names

    private

    def _rom_map
      @map.select do |_, block|
        offset = block['offset']
        bank = (offset >> 16) & 0xff
        page = (offset >> 8) & 0xff
        (((0x00...0x40).include?(bank) || (0x80...0xc0).include?(bank)) &&
         (0x80..0xff).include?(page)) ||
        ((0x40...0x70).include?(bank) && (0x00...0x80).include?(page)) ||
        (0xc0..0xff).include?(bank)
      end
    end
    memoize :_rom_map

    def _ram_map
      @map.select do |_, block|
        offset = block['offset']
        bank = (offset >> 16) & 0xff
        page = (offset >> 8) & 0xff
        (((0x00...0x40).include?(bank) || (0x80...0xc0).include?(bank)) &&
         (0x00...0x20).include?(page)) ||
        ((0x30...0x40).include?(bank) && (0x60...0x80).include?(page)) ||
        (0x70...0x78).include?(bank) ||
        (0x7e...0x80).include?(bank)
      end
    end
    memoize :_ram_map

    # Decompresses commpressed data.
    # @author cabbage
    def decomp(data)
      buffer = []
      i = 0
      bpos = 0
      bpos2 = 0
      while data[i] != 0xff
        cmdtype = data[i] >> 5
        if cmdtype == 7
          cmdtype = (data[i] & 0x1c) >> 2
          len = ((data[i] & 0x03) << 8) + data[i + 1] + 1
          i += 1
        else
          len = (data[i] & 0x1f) + 1
        end
        i += 1
        if cmdtype >= 4
          bpos2 = (data[i] << 8) + data[i + 1]
          i += 2
        end
        case cmdtype
        when 0 # uncompressed?
          buffer[bpos, len] = data[i, len]
          i += len
          bpos += len
        when 1 # RLE?
          buffer.fill(data[i], bpos, len)
          bpos += len
          i += 1
        when 2
          len.times do
            buffer[bpos] = data[i]
            buffer[bpos + 1] = data[i + 1]
            bpos += 2
          end
          i += 2
        when 3 # each byte is one more than previous?
          tmp = data[i]
          i += 1
          len.times do
            buffer[bpos] = tmp
            bpos += 1
            tmp += 1
          end
        when 4 # use previous data?
          buffer[bpos, len] = buffer[bpos2, len]
          bpos += len
        when 5
          len.times do
            tmp = buffer[bpos2]
            bpos2 += 1
            tmp = ((tmp >> 1) & 0x55) | ((tmp << 1) & 0xaa)
            tmp = ((tmp >> 2) & 0x33) | ((tmp << 2) & 0xcc)
            tmp = ((tmp >> 4) & 0x0F) | ((tmp << 4) & 0xf0)
            buffer[bpos] = tmp
            bpos += 1
          end
        when 6
          len.times do
            buffer[bpos] = buffer[bpos2]
            bpos += 1
            bpos2 -= 1
          end
        when 7
          return []
        end
      end
      buffer
    end

    def parse_block(block, full: true)
      offset = block['offset']
      attributes = {
        offset: offset,
        name: block['name'],
        description: block['description']
      }
      return Block.new(**attributes) unless full
      rom_file = ROMFile.new
      if block.has_key?('terminator')
        terminator = attributes[:terminator] = block['terminator']
        data = rom_file.read_until(offset, terminator)
        size = data.length
      else
        size = block['size'] || 1
        attributes[:size] = size
        data = rom_file.read(offset, size)
      end
      attributes[:data] = block['compressed'] ? decomp(data) : data
      case block['type']
      when 'data'
        klass = DataBlock
        attributes[:entries] = []
        if block.has_key?('entries')
          i = 0
          while i < size
            attributes[:entries].concat(block['entries'].map {|entry|
                                          entry = parse_entry(rom_file,
                                                              block,
                                                              entry,
                                                              offset + i)
                                          entry_size = entry.data.length
                                          i += entry_size
                                          entry
                                        })
          end
        end
      when 'assembly'
        klass = AssemblyBlock
        attributes[:arguments] = block['arguments'] || {}
        attributes[:local_vars] = block['localvars'] || {}
        attributes[:labels] = block['labels'] || {}
      when 'empty'
        klass = EmptyBlock
      else
        klass = Block
        attributes[:values] = block['values']
      end
      obj = klass.new(**attributes)
      obj.valid?
      obj
    end

    def find_control_code(rom_file, offset, terminator)
      pc = 0
      cc_lengths = ROMInfo.new.text_tables[:standard].lengths
      loop do
        opcode = rom_file.read_u8(offset + pc)
        pc += 1
        break if opcode == terminator
        num_bytes = cc_lengths[opcode] || 1
        if num_bytes.kind_of?(Hash)
          first_arg = rom_file.read_u8(offset + pc)
          num_bytes = (num_bytes[first_arg] || num_bytes['default'])
        end
        pc += num_bytes - 1
      end
      pc
    end

    def parse_entry(rom_file, block, entry, offset)
      attributes = {
        name: entry['name']
      }
      if entry.has_key?('terminator')
        terminator = attributes[:terminator] = entry['terminator']
        if entry['type'] == 'standardtext'
          size = find_control_code(rom_file, offset, terminator)
          data = rom_file.read(offset, size)
        else
          data = rom_file.read_until(offset, terminator)
          size = data.size
        end
      else
        size = entry['size'] || 1
        # FIXME
        if size.kind_of?(String) && size == 'Size-4'
          #size = entries.find {|entry| entry.name == 'Size'}.data - 4
          size = 1
        end
        data = rom_file.read(offset, size)
      end
      attributes[:size] = size
      attributes[:data] = entry['compressed'] ? decomp(data) : data
      case entry['type']
      when 'pointer'
        klass = PointerEntry
        attributes[:base] = entry['base'] || 0
        attributes[:endianness] = :little
      when 'hilomid pointer'
        klass = PointerEntry
        attributes[:base] = entry['base'] || 0
        attributes[:endianness] = :hilomid
      when 'standardtext'
        klass = TextEntry
        attributes[:text_table] = ROMInfo.new.text_tables[:standard]
      when 'stafftext'
        klass = TextEntry
        attributes[:text_table] = ROMInfo.new.text_tables[:staff]
      when 'int'
        klass = NumberEntry
        attributes[:base] = 10
        attributes[:values] = entry['values']
      when 'hexint'
        klass = NumberEntry
        attributes[:base] = 16
        attributes[:values] = entry['values']
      when 'bytearray'
        klass = ByteArrayEntry
      when 'bitfield'
        klass = BitfieldEntry
        attributes[:bitvalues] = entry['bitvalues']
      when 'tile'
        klass = TileEntry
        attributes[:bpp] = entry['bpp']
        #attributes[:palette] = self[entry['palette']] if entry.has_key?('palette')
      when 'palette'
        klass = PaletteEntry
      else
        klass = UnknownEntry
        attributes[:values] = entry['values']
        attributes[:substtable] = self[entry['substtable']] if entry.has_key?('substtable')
      end
      obj = klass.new(**attributes)
      obj.valid?
      obj
    end
  end
end
