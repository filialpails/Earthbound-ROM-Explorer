class NumberEntry < DataEntry
  validates! :base, presence: true
  validates! :value, absence: true

  attr_accessor :base, :value

  def initialize(**attributes)
    super
    @value = 0
    @size.times do |i|
      @value += @data[i] << (8 * i)
    end
  end

  def pretty_data
    case @base
    when 2 then '0b'
    when 8 then '0'
    when 16 then '0x'
    else ''
    end << @value.to_s(@base)
  end
end
