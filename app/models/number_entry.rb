class NumberEntry < DataEntry
  attr_accessor :base, :value, :values

  validates! :base, :value, presence: true
  validates! :base,  numericality: { only_integer: true, greater_than: 0 }
  validates! :value, numericality: { only_integer: true }

  after_initialize do
    @base ||= 10
    @values ||= []
    @value = 0
    @size.times do |i|
      @value += @data[i] << (8 * i)
    end
  end

  def pretty
    value = @values[@value]
    return value if value
    num = @value.to_s(@base)
    case @base
    when 2 then '0b' << num.rjust(8 * @size, '0')
    when 16 then '0x' << num.rjust(2 * @size, '0')
    else num
    end
  end
end
