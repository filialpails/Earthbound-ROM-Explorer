class NumberEntry < DataEntry
  validates! :base, presence: true
  validates! :value, absence: true

  attr_accessor :base, :value

  def initialize(**attributes)
    super
    @base ||= 10
    @value = 0
    @size.times do |i|
      @value += @data[i] << (8 * i)
    end
  end

  def pretty
    num = @value.to_s(@base)
    case @base
    when 2 then '0b' << num.rjust(8 * @size, '0')
    when 16 then '0x' << num.rjust(2 * @size, '0')
    else num
  end
end
