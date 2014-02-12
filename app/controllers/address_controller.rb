class AddressController < ApplicationController
  def show
    address = params[:address][1, 6].to_i(16)
    rom_filename = Rails.root.join('data', 'Earthbound (U) [!].smc')
    rom_file = File.open(rom_filename, 'rb') do |file|
      ROMFile.new(file)
    end
    ebyaml_filename = Rails.root.join('data', 'eb.yml')
    ebyaml = File.open(ebyaml_filename, 'r') do |file|
      YAML.load_stream(file.read, ebyaml_filename)[1]
    end
    entry = ebyaml[address]
    @entry = ROMEntry.new(entry['offset'], entry['name'], entry['description'])
  end
end
