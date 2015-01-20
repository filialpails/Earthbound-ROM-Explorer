class UnknownEntry < DataEntry
  attr_accessor :values, :substtable

  after_initialize do
    @values ||= []
  end

  def pretty
    data0 = @data.first
    return @substtable.entries[data0 - 1].text if @substtable and data0 > 0
    @values[data0] || @data.map {|byte| byte.to_hex(1)}.join(' ')
  end
end
