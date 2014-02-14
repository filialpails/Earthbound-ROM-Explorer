require 'yaml'

class RAMMap
  attr_reader :entries

  def initialize
    rom_file = ROMFile.new(Rails.root.join('data', 'Earthbound (U) [!].smc'))
    ebyaml = File.open(Rails.root.join('data', 'eb.yml'), 'r') do |file|
      YAML.load_stream(file.read, file.path)[1]
    end
    @entries = []
    ebyaml.each do |address, entry|
      next unless address.instance_of?(Fixnum) && (address >> 16).between?(0x7e, 0x7f)
      @entries << ROMEntry.new(offset: entry['offset'],
                               size: entry['size'] || 1,
                               name: entry['name'],
                               description: entry['description'])
    end
  end
end
