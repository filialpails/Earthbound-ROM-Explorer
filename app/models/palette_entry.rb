class PaletteEntry < DataEntry
  attr_accessor :colors, :data_uri

  validates! :colors, presence: true, length: { minimum: 4 }
  validates! :data_uri, presence: true, length: { minimum: 23 }

  after_initialize do
    @colors = read_palette
    @data_uri = 'data:image/png;base64,' << Base64.strict_encode64(ChunkyPNG::Image.new(@colors.length, 1, @colors.map {|color| (color << 8) | 0xff}).to_blob(:best_compression))
  end

  private

  def read_color(i)
    index = i * 2
    bgr = (@data[index] << 8) | @data[index + 1]
    r = (bgr & 0x1f) << 3
    g = ((bgr >> 5) & 0x1f) << 3
    b = ((bgr >> 10) & 0x1f) << 3
    (r << 16) | (g << 8) | b
  end

  def read_palette
    num_colors = @size / 2
    (0...num_colors).map do |i|
      read_color(i)
    end
  end
end
