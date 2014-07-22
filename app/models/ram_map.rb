require 'ebyaml'
require 'rom_file'

class RAMMap < ApplicationModel
  attr_reader :entries

  def initialize(**attributes)
    super
    rom_file = ROMFile.new
    @entries = []
    EBYAML.map.each do |address, entry|
      next unless address.is_a?(Fixnum) && (address >> 16).between?(0x7e, 0x7f)
      @entries << ROMEntry.new(offset: entry['offset'],
                               size: entry['size'] || 1,
                               name: entry['name'],
                               description: entry['description'])
    end
  end
end
