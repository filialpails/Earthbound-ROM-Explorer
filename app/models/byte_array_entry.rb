class ByteArrayEntry < DataEntry
  def pretty
    @data.map {|byte| byte.to_hex(1)}.join(' ')
  end
end
