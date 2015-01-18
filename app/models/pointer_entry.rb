class PointerEntry < DataEntry
  attr_accessor :endianness, :base

  validates! :endianness, inclusion: {
    in: %i[big little hilomid]
  }
  validates! :base, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000000,
    less_than_or_equal_to:    0xffffff
  }

  after_initialize do
    @endianness ||= :little
    @base ||= 0
  end

  def pretty
    '$' << (@base + case @endianness
                    when :big then bytes_to_fixnum(*@data.reverse)
                    when :little then bytes_to_fixnum(*@data)
                    when :hilomid then bytes_to_fixnum(@data[1], @data[2], @data[0])
                    end).to_hex(3)
  end

  private

  def bytes_to_fixnum(lo, mid, hi = 0, zero = 0)
    (hi << 16) | (mid << 8) | lo
  end
end
