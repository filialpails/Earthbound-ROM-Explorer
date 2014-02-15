class PaletteEntry < ROMEntry
  validates :colours, absence: true

  attr_readonly :colours

  def initialize(**attributes)
    super
    @colours = []
    read_palette
  end

  private

  def read_colour(b, offset = 0)
    b[offset] ||= 0
    b[offset + 1] ||= 0
    bgr_block = ((b[offset] & 0xff) | ((b[offset + 1] & 0xff) << 8)) & 0x7fff
    [(bgr_block & 0x1f) * 8, ((bgr_block >> 5) & 0x1f) * 8, (bgr_block >> 10) * 8]
  end

  def read_palette(b, offset = 0)
    num_colours = @size / 2
    @colours = (0..num_colours).map do |i|
      read_colour(b, offset + i * 2)
    end
  end
end
