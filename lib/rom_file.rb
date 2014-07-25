class ROMFile
  HEADER_OFFSET_LOROM = 0x007fc0
  HEADER_OFFSET_HIROM = 0x00ffc0
  HEADER_FIELDS = {
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
    if read_u16(HEADER_OFFSET_LOROM + HEADER_FIELDS[:complement]) |
        read_u16(HEADER_OFFSET_LOROM + HEADER_FIELDS[:checksum]) == 0xffff
      @layout = :LoROM
    elsif read_u16(HEADER_OFFSET_HIROM + HEADER_FIELDS[:complement]) |
        read_u16(HEADER_OFFSET_HIROM + HEADER_FIELDS[:checksum]) == 0xffff
      @layout = :HiROM
    else
      fail 'Invalid ROM file: neither HiROM nor LoROM detected'
    end
  end

  # Read bytes.
  #
  # @param addr [Fixnum] SNES address to read from
  # @param length [Fixnum] how many bytes to read
  # @return [Array<Fixnum>] array of bytes read from the ROM
  def read(addr, length = 1)
    @rom.seek(snes2file(addr))
    @rom.read(length).bytes
  end

  # Read an unsigned byte.
  #
  # @param addr [Fixnum] SNES address to read from
  # @return [Fixnum] byte read from the ROM
  def read_u8(addr)
    @rom.seek(snes2file(addr))
    @rom.readbyte
  end

  # Read an unsigned word (two bytes).
  #
  # @param addr [Fixnum] SNES address to read from
  # @return [Fixnum] word read from the ROM
  def read_u16(addr)
    @rom.seek(snes2file(addr))
    @rom.readbyte | (@rom.readbyte << 8)
  end

  # Read a signed byte.
  #
  # @param addr [Fixnum] SNES address to read from
  # @return [Fixnum] byte read from the ROM
  def read_s8(addr)
    @rom.seek(snes2file(addr))
    @rom.read(1).unpack('c')[0]
  end

  # Read a signed word (two bytes).
  #
  # @param addr [Fixnum] SNES address to read from
  # @return [Fixnum] word read from the ROM
  def read_s16(addr)
    @rom.seek(snes2file(addr))
    @rom.read(2).unpack('s>')[0]
  end

  # Read bytes until a terminator byte is found. The terminator is included in
  #   the returned bytes.
  #
  # @param addr [Fixnum] SNES address to read from
  # @return [Array<Fixnum>] array of bytes read from the ROM
  def read_until(addr, terminator)
    @rom.seek(snes2file(addr))
    buffer = []
    buffer << @rom.readbyte until buffer.last == terminator
    buffer
  end

  private

  # Converts a SNES address to a ROM file offset.
  #
  # @param addr [Fixnum] SNES address
  # @return [Fixnum] ROM file offset
  # @author  byuu
  # @version 14
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
