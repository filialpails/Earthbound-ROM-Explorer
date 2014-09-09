class PaletteEntry < DataEntry
  validates! :colours, absence: true

  attr_accessor :colours

  def initialize(**attributes)
    super
    @colours = read_palette
  end

  private

  def read_colour(i)
    bgr = (@data[i * 2] << 8) | @data[i * 2 + 1]
    r = (bgr & 0x1f) << 3
    g = ((bgr >> 5) & 0x1f) << 3
    b = ((bgr >> 10) & 0x1f) << 3
    (r << 16) | (g << 8) | b
  end

  def read_palette
    num_colours = @size / 2
    (0...num_colours).map do |i|
      read_colour(i)
    end
  end
end
