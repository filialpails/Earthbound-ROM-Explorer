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
