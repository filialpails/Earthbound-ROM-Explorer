require 'yaml'

class ROMFile
  def initialize(io)
    @rom = io.read
    # Verify this is a correct ROM.
    case @rom.length % (1024 * 1024)
    when 0 then @header = false
    when 512 then @header = true
    else abort 'Invalid ROM file'
    end
    @romtype = :HiROM
  end

  def read(addr, length)
    @rom[snes2file(addr), length]
  end

  private

  # Converts SNES address to file offset.
  # @author  byuu
  # @version v14
  def snes2file(addr)
    case @romtype
    when :LoROM
      addr = ((addr & 0x7f0000) >> 1) + (addr & 0x007fff)
    when :HiROM
      addr &= 0x3fffff
    else
      addr &= 0xffffff
    end
    addr += 0x000200 if (@header)
    addr
  end
end

class ROMEntry
  attr_reader :offset, :name, :description

  def initialize(offset, name, description)
    @offset = offset
    @name = name
    @description = description
  end
end

class ROMMap
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
      next if address.class != Fixnum
      bank = address & 0xff0000
      offset = address & 0x00ffff
      next unless bank.between?(0xc0, 0xff) || bank.between?(0x40, 0x7d) ||
        ((bank.between?(0x00, 0x3f) || bank.between?(0x80, 0xbf)) &&
         address.between?(0x8000, 0xffff))
      @entries << ROMEntry.new(entry['offset'],
                               entry['name'],
                               entry['description'])
    end
  end
end

class RAMMap
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
      bank = address & 0xff0000
      offset = address & 0x00ffff
      next unless bank.within?(0x7e...0x7f)
      @entries << ROMEntry.new
    end
  end
end
