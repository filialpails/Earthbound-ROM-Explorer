class ROMEntry
  attr_reader :offset, :name, :description

  def initialize(offset, name = nil, description = nil, data = nil)
    @offset = offset
    @name = name
    @description = description
    @data = data
  end
end

class IntEntry < ROMEntry
  def initialize(offset, name, description, data, base)
    super
  end
end

class StandardTextEntry < ROMEntry
  @text_table = {}

  def initialize(offset, name, description, data)
    super
  end

  def decode
  end
end

class StaffTextEntry < ROMEntry
  @text_table = {}

  def initialize(offset, name, description, data)
    super
  end

  def decode
  end
end

class ASMEntry < ROMEntry
  def initialize(offset, name, description, data)
    super
  end
end

class GraphicsEntry < ROMEntry
  # Decompresses commpressed data.
  # @author cabbage
  def decomp(cdata, buffer, maxlen)
    i = 0
    bpos = 0
    bpos2 = 0
    while cdata[i] != 0xFF
      cmdtype = cdata[i] >> 5
      len = (cdata[i] & 0x1F) + 1
      if cmdtype == 7
        cmdtype = (cdata[i] & 0x1C) >> 2
        len = ((cdata[i] & 3) << 8) + cdata[i + 1] + 1
        i += 1
      end
      return -1 if (len > maxlen)
      i += 1
      if cmdtype >= 4
        bpos2 = (cdata[i] << 8) + cdata[i + 1]
        return -1 if bpos2 >= maxlen
        i += 2
      end
      case cmdtype
      when 0 # uncompressed?
        buffer[bpos, len] = cdata[i, len]
        i += len
        bpos += len
      when 1 # RLE?
        buffer.fill(cdata[i], bpos, len)
        bpos += len
        i += 1
      when 2
        return -1 if bpos + 2 * len > maxlen
        while len != 0
          len -= 1
          buffer[bpos] = cdata[i]
          buffer[bpos] = cdata[i + 1]
          bpos += 2
        end
        i += 2
      when 3 # each byte is one more than previous?
        tmp = cdata[i]
        i += 1
        while len != 0
          len -= 1
          buffer[bpos] = tmp
          bpos += 1
          tmp += 1
        end
      when 4 # use previous data?
        return -1 if bpos2 + len > maxlen
        buffer[bpos, len] = buffer[bpos2, len]
        bpos += len
      when 5
        return -1 if bpos2 + len > maxlen
        while len != 0
          len -= 1
          tmp = buffer[bpos2]
          bpos2 += 1
          tmp = ((tmp >> 1) & 0x55) | ((tmp << 1) & 0xAA)
          tmp = ((tmp >> 2) & 0x33) | ((tmp << 2) & 0xCC)
          tmp = ((tmp >> 4) & 0x0F) | ((tmp << 4) & 0xF0)
          buffer[bpos] = tmp
          bpos += 1
        end
      when 6
        return -1 if bpos2 - len + 1 < 0
        while len != 0
          len -= 1
          buffer[bpos] = buffer[bpos2]
          bpos += 1
          bpos2 -= 1
        end
      when 7
        return -1
      end
    end
    buffer.length
  end
end
