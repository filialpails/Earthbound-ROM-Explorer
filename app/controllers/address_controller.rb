require 'rom_file'

class AddressController < ApplicationController
  def show
    rom_file = ROMFile.new
    @entry = parse_entry(rom_file,
                         ROMMap.find(params[:address].delete('$').to_i(16)))
  end

  private

  def parse_entry(rom_file, entry)
    offset = entry['offset']
    attributes = {
      offset: offset,
      name: entry['name'],
      description: entry['description']
    }
    if entry.has_key?('terminator')
      terminator = entry['terminator']
      attributes[:terminator] = terminator
      attributes[:data] = rom_file.read_until(offset, terminator)
      size = attributes[:data].length
    else
      size = entry['size'] || 1
      attributes[:size] = size
      attributes[:data] = rom_file.read(offset, size)
    end
    case entry['type']
    when 'data'
      klass = DataEntry
      if entry.has_key?('entries')
        entry_offset = offset
        attributes[:entries] = []
        i = 0
        while i < size
          subentry_size = 1
          attributes[:entries].concat(entry['entries'].map {|entry|
            subentry = parse_subentry(rom_file, entry, entry_offset)
            subentry_size = subentry.data.length
            i += subentry_size
            entry_offset += subentry_size
            subentry
          })
        end
      else
        attributes[:entries] = []
      end
    when 'assembly'
      klass = AssemblyEntry
      attributes[:arguments] = entry['arguments'] || {}
      attributes[:local_vars] = entry['localvars'] || {}
      attributes[:labels] = entry['labels'] || {}
    else
      klass = ROMEntry
    end
    klass.new(**attributes)
  end

  def parse_subentry(rom_file, subentry, offset)
    attributes = {
      name: subentry['name']
    }
    if subentry.has_key?('terminator')
      terminator = subentry['terminator']
      attributes[:terminator] = terminator
      attributes[:data] = rom_file.read_until(offset, terminator)
    else
      size = subentry['size'] || 1
      attributes[:size] = size
      attributes[:data] = rom_file.read(offset, size)
    end
    case subentry['type']
    when 'pointer'
      klass = PointerEntry
      attributes[:base] = subentry['base'] || 0
      attributes[:endianness] = subentry['endianness'] || :l
    when 'hilomid pointer'
      klass = PointerEntry
      attributes[:base] = subentry['base'] || 0
      attributes[:endianness] = subentry['endianness'] || :m
    when 'standardtext'
      klass = TextEntry
      attributes[:text_table] = ROMInfo.new.text_tables['standardtext']
    when 'stafftext'
      klass = TextEntry
      attributes[:text_table] = ROMInfo.new.text_tables['stafftext']
    when 'int'
      klass = NumberEntry
      attributes[:base] = 10
    when 'hexint'
      klass = NumberEntry
      attributes[:base] = 16
    when 'bytearray'
      klass = ByteArrayEntry
    when 'bitfield'
      klass = BitfieldEntry
      attributes[:bitvalues] = subentry['bitvalues']
    when 'tile'
      klass = TileEntry
      attributes[:bpp] = subentry['bpp']
      attributes[:palette] = subentry['palette']
    when 'palette'
      klass = PaletteEntry
    else
      klass = UnknownEntry
    end
    klass.new(**attributes)
  end
end
