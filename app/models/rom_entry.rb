class ROMEntry < ApplicationModel
  validates :offset, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000000,
    less_than_or_equal_to:    0xffffff
  }
  validates :size, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000001,
    less_than_or_equal_to:    0xffffff
  }
  validates :terminator, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x00,
    less_than_or_equal_to:    0xff
  }
  validates :compressed, inclusion: { in: [true, false] }
  validates :data, presence: true, length: { minimum: 1 }

  attr_readonly :offset, :size, :terminator, :name, :description, :compressed, :data

  def initialize(**attributes)
    super
    # if neither size nor terminator given, set size to 1 byte
    @size = 1 unless @size || @terminator
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
          buffer[bpos + 1] = @data[i + 1]
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
