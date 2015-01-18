class UnknownEntry < DataEntry
  attr_accessor :values, :substtable

  after_initialize do
    @values ||= []
  end

  def pretty
    return @substtable.entries[@data[0] - 1].text if @substtable and @data[0] > 0
    @values[@data[0]] || @data.map {|byte| byte.to_hex(1)}.join(' ')
  end
end
