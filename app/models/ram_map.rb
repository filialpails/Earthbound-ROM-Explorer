require 'yaml'

class RAMMap
  attr_reader :entries

  def initialize
    rom_filename = Rails.root.join('data', 'Earthbound (U) [!].smc')
    rom_file = File.open(rom_filename, 'rb') do |file|
      ROMFile.new(file)
    end
    ebyaml_filename = Rails.root.join('data', 'eb.yml')
    ebyaml = File.open(ebyaml_filename, 'r') do |file|
      YAML.load_stream(file.read, ebyaml_filename)[1]
    end
    @entries = []
    ebyaml.each do |address, entry|
      next unless address.instance_of?(Fixnum)
      bank = address >> 16
      next unless bank.between?(0x7e, 0x7f)
      @entries << ROMEntry.new(entry['offset'],
                               entry['name'],
                               entry['description'])
    end
  end
end
