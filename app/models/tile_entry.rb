require 'chunky_png'
require 'base64'

class TileEntry < DataEntry
  attr_accessor :image, :bpp, :palette, :data_uri

  validates! :size, numericality: { equal_to: 16 }, if: ->(tile_entry){tile_entry.bpp == 2}
  validates! :size, numericality: { equal_to: 32 }, if: ->(tile_entry){tile_entry.bpp == 4}
  validates! :bpp, presence: true, inclusion: [2, 4]
  validates! :image, presence: true, length: { minimum: 1 }
  validates! :data_uri, presence: true, length: { minimum: 23 }

  after_initialize do
    @image = []
    case @bpp
    when 2 then read_2bpp_image
    when 4 then read_4bpp_image
    end
    palette = @palette ? @palette.colors : [0x00000000].concat((0..15).map {|i| (0x11111100 * i) | 0xff})
    @data_uri = 'data:image/png;base64,' << Base64.strict_encode64(ChunkyPNG::Image.new(8, 8, @image.flatten.map {|index| palette[index]}).to_blob(:best_compression))
  end

  private

  def read_2bpp_image(offset = 0, bit_offset = 0)
    8.times do |i|
      byte_index = i * 2 + offset
      b1 = @data[byte_index]
      b2 = @data[byte_index + 1]
      @image[i] ||= [0, 0, 0, 0, 0, 0, 0, 0]
      row = @image[i]
      8.times do |j|
        bit_index = 7 - j
        row[j] |= ((b2[bit_index] << 1) | b1[bit_index]) << bit_offset
      end
    end
  end

  def read_4bpp_image
    read_2bpp_image
    read_2bpp_image(16, 2)
  end

  def read_8bpp_image
    read_2bpp_image
    read_2bpp_image(16, 2)
    read_2bpp_image(32, 4)
    read_2bpp_image(48, 6)
  end
end
