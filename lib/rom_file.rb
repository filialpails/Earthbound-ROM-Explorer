class ROMFile
  attr_reader :header, :layout

  def initialize
    @rom = File.open(Rails.configuration.rom_location, 'rb')
    @rom.advise(:random)
    # Verify this is a correct ROM.
    case @rom.size % (1024 * 1024)
    when 0 then @header = false
    when 512 then @header = true
    else fail 'Invalid ROM file: not a valid size'
    end
    header_offset_lorom = 0x007fc0
    header_offset_hirom = 0x00ffc0
    header_fields = {
      cart_name: 0x00,
      mapper: 0x15,
      rom_type: 0x16,
      rom_size: 0x17,
      ram_size: 0x18,
      cart_region: 0x19,
      company: 0x1a,
      version: 0x1b,
      complement: 0x1c,
      checksum: 0x1e,
      reset_vector: 0x3c
    }
    if read_u16(header_offset_lorom + header_fields[:complement]) |
        read_u16(header_offset_lorom + header_fields[:checksum]) == 0xffff
      @layout = :LoROM
    elsif read_u16(header_offset_hirom + header_fields[:complement]) |
        read_u16(header_offset_hirom + header_fields[:checksum]) == 0xffff
      @layout = :HiROM
    else
      fail 'Invalid ROM file: neither HiROM nor LoROM detected'
    end
  end

  def read(addr, length = 1)
    @rom.seek(snes2file(addr))
    @rom.read(length).bytes
  end

  def read_u8(addr)
    @rom.seek(snes2file(addr))
    @rom.readbyte
  end

  def read_u16(addr)
    @rom.seek(snes2file(addr))
    @rom.readbyte | (@rom.readbyte << 8)
  end

  def read_s8(addr)
    @rom.seek(snes2file(addr))
    @rom.read(1).unpack('c')[0]
  end

  def read_s16(addr)
    @rom.seek(snes2file(addr))
    @rom.read(2).unpack('s>')[0]
  end

  def read_until(addr, terminator)
    @rom.seek(snes2file(addr))
    buffer = []
    buffer << @rom.readbyte until buffer.last == terminator
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
