class PointerEntry < DataEntry
  validates :endianness, inclusion: {
    in: %i[big little hilomid]
  }
  validates :base, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000000,
    less_than_or_equal_to:    0xffffff
  }

  attr_accessor :endianness, :base

  def initialize(**attributes)
    super
    @endianness ||= :little
    @base ||= 0
  end

  def pretty
    '$' << (@base + case @size
                    when 2
                      case @endianness
                      when :big then (@data[0] << 8) | @data[1]
                      when :little then (@data[1] << 8) | @data[0]
                      end
                    when 3
                      case @endianness
                      when :big then (@data[0] << 16) | (@data[1] << 8) | @data[2]
                      when :little then (@data[2] << 16) | (@data[1] << 8) | @data[0]
                      when :hilomid then (@data[0] << 16) | (@data[2] << 8) | @data[1]
                      end
                    end).to_hex(3)
  end
end
