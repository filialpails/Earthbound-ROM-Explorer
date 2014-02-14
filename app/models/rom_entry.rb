class ROMEntry < ApplicationModel
  validates :offset, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000000,
    less_than_or_equal_to:    0xffffff
  }
  validates :size, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000001,
    less_than_or_equal_to:    0xffffff
  }
  validates :compressed, inclusion: { in: [true, false] }
  validates :data, presence: true, length: { minimum: 1 }

  attr_readonly :offset, :size, :terminator, :name, :description, :compressed, :data

  def initialize(**attributes)
    super
    # if neither size nor terminator given, set size to 1 byte
    @size ||= 1 unless @terminator
    @compressed ||= false
    if @compreesed
      @compressed_data = @data
      @data = decomp
    end
  end

  def id
    @offset
  end

  # Decompresses commpressed data.
  # @author cabbage
  def decomp
    buffer = []
    i = 0
    bpos = 0
    bpos2 = 0
    while @data[i] != 0xff
      cmdtype = @data[i] >> 5
      if cmdtype == 7
        cmdtype = (@data[i] & 0x1c) >> 2
        len = ((@data[i] & 0x03) << 8) + @data[i + 1] + 1
        i += 1
      else
        len = (@data[i] & 0x1f) + 1
      end
      i += 1
      if cmdtype >= 4
        bpos2 = (@data[i] << 8) + @data[i + 1]
        i += 2
      end
      case cmdtype
      when 0 # uncompressed?
        buffer[bpos, len] = @data[i, len]
        i += len
        bpos += len
      when 1 # RLE?
        buffer.fill(@data[i], bpos, len)
        bpos += len
        i += 1
      when 2
        while len != 0
          len -= 1
          buffer[bpos] = @data[i]
          buffer[bpos] = @data[i + 1]
          bpos += 2
        end
        i += 2
      when 3 # each byte is one more than previous?
        tmp = @data[i]
        i += 1
        while len != 0
          len -= 1
          buffer[bpos] = tmp
          bpos += 1
          tmp += 1
        end
      when 4 # use previous data?
        buffer[bpos, len] = buffer[bpos2, len]
        bpos += len
      when 5
        while len != 0
          len -= 1
          tmp = buffer[bpos2]
          bpos2 += 1
          tmp = ((tmp >> 1) & 0x55) | ((tmp << 1) & 0xaa)
          tmp = ((tmp >> 2) & 0x33) | ((tmp << 2) & 0xcc)
          tmp = ((tmp >> 4) & 0x0F) | ((tmp << 4) & 0xf0)
          buffer[bpos] = tmp
          bpos += 1
        end
      when 6
        while len != 0
          len -= 1
          buffer[bpos] = buffer[bpos2]
          bpos += 1
          bpos2 -= 1
        end
      when 7
        return []
      end
    end
    buffer
  end
end

class ArrayEntry < ROMEntry
  validates :entries, presence: true, length: { minimum: 1 }

  attr_readonly :entries
end

class NumberEntry < ROMEntry
  validates :base, presence: true
  validates :value, absence: true

  attr_readonly :base, :value

  def initialize(**attributes)
    super
    @value = 0
    @size.times do |i|
      @value += @data[i] << (8 * (i + 1))
    end
  end
end

class PointerEntry < ROMEntry
  validates :endianness, inclusion: {
    in: %i[big little middle]
  }
  validates :base, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000000,
    less_than_or_equal_to:    0xffffff
  }

  attr_readonly :endianness, :base

  def initialize(**attributes)
    super
    @endianness ||= :little
    @base ||= 0
  end
end

class ByteArrayEntry < ROMEntry
end

class BitfieldEntry < ROMEntry
  attr_readonly :bitvalues
end

class TextTable < ApplicationModel
  validates :name, presence: true
  validates :lengths, presence: true
  validates :replacements, presence: true

  attr_readonly :name, :lengths, :replacements

  def id
    @name
  end
end

class TextEntry < ROMEntry
  validates :text_table, presence: true
  validates :text, absence: true

  attr_readonly :text_table, :text

  def initialize(**attributes)
    super
    @text = ''
    decode
  end

  private

  def decode
    cc_lengths = @text_table.lengths
    replacements = @text_table.replacements
    @data.length.times do |i|
      opcode = @data[i]
      if [0x15, 0x16, 0x17].include?(opcode)
        i += 1
        @text << replacements[opcode][@data[i]]
      elsif replacements.has_key?(opcode)
        @text << replacements[opcode]
      elsif opcode >= 0x00 && opcode <= 0x1f
        operand_length = 1
        if cc_lengths[opcode]
          operand_length = cc_lengths[opcode]
        end
        if operand_length.instance_of?(Array)
          if operand_length[@data[i + 1]]
            operand_length = operand_length[@data[i + 1]]
          else
            operand_length = operand_length['default']
          end
        end
        operand_length -= 1
        args = ''
        operand_length.times do |j|
          i += 1
          args << ' ' << @data[i].to_hex(6)
        end
        @text << "[#{opcode.to_hex(3)}#{args}]"
      end
    end
  end
end

class AssemblyEntry < ROMEntry
  attr_readonly :labels, :arguments, :local_vars
end

class TileEntry < ROMEntry
  validates :bpp, presence: true
  validates :image, absence: true

  attr_readonly :image, :bpp, :palette

  def initialize(**attributes)
    super
    @image = []
    case @bpp
    when 2 then read_2bpp_image(0, 0, 0)
    when 4 then read_4bpp_image(0, 0, 0)
    end
  end

  private

  def read_2bpp_image(offset, x, y, bit_offset = 0)
    8.times do |i|
      iy = i + y
      @image[iy] ||= []
      2.times do |k|
        b = @data[offset]
        offset += 1
        k_bit_offset = k + bit_offset
        8.times do |j|
          index = (7 - j) + x
          @image[iy][index] ||= 0
          @image[iy][index] |= ((b & (1 << j)) >> j) << k_bit_offset
        end
      end
    end
  end

  def read_4bpp_image(source, offset, x, y, bit_offset = 0)
    read_2bpp_image(source, offset,      x, y, bit_offset)
    read_2bpp_image(source, offset + 16, x, y, bit_offset + 2)
    32
  end
end

class PaletteEntry < ROMEntry
  validates :colours, absence: true

  attr_readonly :colours

  def initialize(**attributes)
    super
    @colours = []
    read_palette
  end

  private

  def read_colour(b, offset = 0)
    b[offset] ||= 0
    b[offset + 1] ||= 0
    bgr_block = ((b[offset] & 0xff) | ((b[offset + 1] & 0xff) << 8)) & 0x7fff
    [(bgr_block & 0x1f) * 8, ((bgr_block >> 5) & 0x1f) * 8, (bgr_block >> 10) * 8]
  end

  def read_palette(b, offset = 0)
    num_colours = @size / 2
    @colours = (0..num_colours).map do |i|
      read_colour(b, offset + i * 2)
    end
  end
end
