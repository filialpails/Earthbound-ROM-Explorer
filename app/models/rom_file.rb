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
    addr += 0x000200 if @header
    addr
  end
end
