class ROMFile
  attr_reader :header, :layout

  def initialize
    @rom = File.open(Rails.configuration.rom_location, 'rb')
    @rom.advise(:random)
    # Verify this is a correct ROM.
    case @rom.size % (1024 * 1024)
    when 0 then @header = false
    when 512 then @header = true
    else abort 'Invalid ROM file'
    end
    # TODO: read layout from ROM?
    @layout = :HiROM
  end

  def read(addr, length = 1)
    @rom.seek(snes2file(addr))
    @rom.read(length).bytes
  end

  def read_until(addr, terminator)
    @rom.seek(snes2file(addr))
    buffer = []
    buffer << @rom.read(1).bytes.first until buffer.last == terminator
    buffer
  end

  private

  # Converts SNES address to file offset.
  # @author  byuu
  # @version v14
  def snes2file(addr)
    addr = case @layout
           when :LoROM then ((addr & 0x7f0000) >> 1) + (addr & 0x007fff)
           when :HiROM then addr & 0x3fffff
           else addr & 0xffffff
           end
    addr += 0x000200 if @header
    addr
  end
end
