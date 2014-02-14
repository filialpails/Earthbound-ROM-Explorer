class AddressController < ApplicationController
  def show
    address = params[:address][1, 6].to_i(16)
    rom_file = ROMFile.new(Rails.root.join('data', 'Earthbound (U) [!].smc'))
    ebyaml = File.open(Rails.root.join('data', 'eb.yml'), 'r') do |file|
      YAML.load_stream(file.read, file.path)[1]
    end
    entry = ebyaml[address]
    offset = entry['offset']
    size = entry['size']
    terminator = entry['terminator']
    data = rom_file.read(offset, size)
    name = entry['name']
    description = entry['description']
    klass = ROMEntry
    @entry = case entry['type']
             when 'pointer'
               PointerEntry.new(offset: offset,
                                size: size,
                                name: name,
                                description: description,
                                base: entry['base'] || 0)
             when 'hilomid pointer'
               PointerEntry.new(offset: offset,
                                size: size,
                                name: name,
                                description: description,
                                base: entry['base'] || 0,
                                endianness: :middle)
             when 'standardtext'
               TextEntry.new(offset: offset,
                             size: size,
                             name: name,
                             description: description,
                             text_table: ROMInfo.new.text_tables['standardtext'])
             # TODO: stafftext, hexint, int, bytearray, bitfield, tile, palette
             else
               ROMEntry.new(offset: offset,
                            size: size,
                            terminator: terminator,
                            name: name,
                            description: description,
                            data: data)
             end
  end
end
