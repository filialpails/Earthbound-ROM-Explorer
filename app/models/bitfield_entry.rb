class BitfieldEntry < DataEntry
  validates! :bitvalues, presence: true, length: { minimum: 1 }

  attr_accessor :bitvalues

  def pretty
    pretty = {}
    @data.each_index do |i|
      byte = @data[i]
      8.times do |j|
        pretty[@bitvalues[i * 8 + j]] = byte[j] == 1
      end
    end
    pretty
  end
end
