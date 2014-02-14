require 'yaml'

class ROMMap
  attr_reader :entries

  def initialize
    @entries = []
    # TODO: read rom filename from config file
    rom_file = ROMFile.new(Rails.root.join('data', 'Earthbound (U) [!].smc'))
    # TODO: read yaml filename from config file
    ebyaml = File.open(Rails.root.join('data', 'eb.yml'), 'r') do |file|
      YAML.load_stream(file.read, file.path)[1]
    end
    ebyaml.each do |address, entry|
      next unless address.instance_of?(Fixnum)
      bank = address >> 16
      offset = address & 0x00ffff
      # ignore addresses outside ROM banks
      next unless bank.between?(0xc0, 0xff) || bank.between?(0x40, 0x7d) ||
        ((bank.between?(0x00, 0x3f) || bank.between?(0x80, 0xbf)) &&
         address.between?(0x8000, 0xffff))
      @entries << ROMEntry.new(offset: entry['offset'],
                               size: entry['size'] || 1,
                               name: entry['name'],
                               description: entry['description'])
    end
  end
end
