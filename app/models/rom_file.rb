class ROMFile
  attr_reader :header, :layout

  def initialize(filename)
    @rom = File.open(filename, 'rb')
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

  private

  # Converts SNES address to file offset.
  # @author  byuu
  # @version v14
  def snes2file(addr)
    case @layout
    when :LoROM
      addr = ((addr & 0x7f0000) >> 1) + (addr & 0x007fff)
    when :HiROM
      addr &= 0x3fffff
    else
      addr &= 0xffffff
    end
    addr += 0x000200 if @header
    addr
  end
end
