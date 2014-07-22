class PointerEntry < ROMEntry
  VIEW_NAME = 'pointer'

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
    @endianness ||= :l
    @base ||= 0
  end

  def pretty_data
    '$' << (case @endianness
    when :l then @base + ((@data[2] << 16) | (@data[1] << 8) | @data[0])
    when :m then @base + ((@data[0] << 16) | (@data[2] << 8) | @data[1])
    end).to_s(16)
  end
end
