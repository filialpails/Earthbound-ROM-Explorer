class AddressController < ApplicationController
  def show
    address = params[:address]
    address = address[1, 6] if address.first == '$'
    address = address.to_i(16)
    rom_file = ROMFile.new
    @entry = parse_entry(rom_file, ROMMap.find(address))
    # TODO: render different view depending on entry type? use partials?
  end

  private

  def parse_entry(rom_file, entry)
    offset = entry['offset']
    attributes = {
      offset: offset,
      name: entry['name'],
      description: entry['description']
    }
    size = entry['size']
    terminator = entry['terminator']
    if size
      attributes[:size] = size
      attributes[:data] = rom_file.read(offset, size)
    elsif terminator
      attributes[:terminator] = terminator
      attributes[:data] = rom_file.read_until(offset, terminator)
    end
    case entry['type']
    when 'pointer'
      klass = PointerEntry
      attributes[:base] = entry['base'] || 0
      attributes[:endianness] = :little
    when 'hilomid pointer'
      klass = PointerEntry
      attributes[:base] = entry['base'] || 0
      attributes[:endianness] = :middle
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
    when 'tile'
      klass = TileEntry
    when 'palette'
      klass = PaletteEntry
    when 'data'
      klass = DataEntry
      # TODO: figure out offset of subentries
      # attributes['entries'] = entry['entries'].map do |entry|
      #   parse_entry(rom_file, entry)
      # end
    when 'assembly'
      klass = AssemblyEntry
    else
      klass = ROMEntry
    end
    klass.new(**attributes)
  end
end
