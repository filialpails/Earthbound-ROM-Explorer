class TileEntry < DataEntry
  validates :bpp, presence: true
  validates :image, absence: true

  attr_accessor :image, :bpp, :palette

  def initialize(**attributes)
    super
    @image = []
    case @bpp
    when 2 then read_2bpp_image
    when 4 then read_4bpp_image
    end
  end

  private

  def read_2bpp_image(offset = 0, bit_offset = 0)
    8.times do |i|
      @image[i] ||= []
      image_i = @image[i]
      2.times do |k|
        b = @data[offset]
        offset += 1
        k_bit_offset = k + bit_offset
        8.times do |j|
          index = 7 - j
          image_i[index] ||= 0
          image_i[index] |= ((b & (1 << j)) >> j) << k_bit_offset
        end
      end
    end
  end

  def read_4bpp_image
    read_2bpp_image
    read_2bpp_image(16, 2)
  end
end
