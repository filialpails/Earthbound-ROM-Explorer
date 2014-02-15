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
