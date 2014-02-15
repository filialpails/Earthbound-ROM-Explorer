class TileEntry < ROMEntry
  validates :bpp, presence: true
  validates :image, absence: true

  attr_readonly :image, :bpp, :palette

  def initialize(**attributes)
    super
    @image = []
    case @bpp
    when 2 then read_2bpp_image(0, 0, 0)
    when 4 then read_4bpp_image(0, 0, 0)
    end
  end

  private

  def read_2bpp_image(offset, x, y, bit_offset = 0)
    8.times do |i|
      iy = i + y
      @image[iy] ||= []
      2.times do |k|
        b = @data[offset]
        offset += 1
        k_bit_offset = k + bit_offset
        8.times do |j|
          index = (7 - j) + x
          @image[iy][index] ||= 0
          @image[iy][index] |= ((b & (1 << j)) >> j) << k_bit_offset
        end
      end
    end
  end

  def read_4bpp_image(source, offset, x, y, bit_offset = 0)
    read_2bpp_image(source, offset,      x, y, bit_offset)
    read_2bpp_image(source, offset + 16, x, y, bit_offset + 2)
    32
  end
end
