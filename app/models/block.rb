class Block
  include ActiveModel::Model

  validates! :offset, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000000,
    less_than_or_equal_to:    0xffffff
  }
  validates :size, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000001,
    less_than_or_equal_to:    0xffffff
  }
  validates :terminator, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x00,
    less_than_or_equal_to:    0xff
  }
  validates :compressed, inclusion: { in: [true, false] }
  validates! :data, presence: true, length: { minimum: 1 }

  attr_accessor :offset, :size, :terminator, :name, :description, :compressed, :data

  def initialize(**attributes)
    super
    # if neither size nor terminator given, set size to 1 byte
    @size = 1 unless @size || @terminator
  end

  def id
    @offset
  end
end
