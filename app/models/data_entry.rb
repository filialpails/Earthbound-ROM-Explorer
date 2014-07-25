class DataEntry
  include ActiveModel::Model

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
  validates :data, presence: true, length: { minimum: 1 }

  attr_accessor :size, :terminator, :name, :compressed, :data
end
