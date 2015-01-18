class Block
  include ActiveModel::Model

  attr_accessor :offset, :size, :terminator, :name, :description, :compressed, :data

  validates! :offset, presence: true, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000000,
    less_than_or_equal_to:    0xffffff
  }
  validates! :size, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000001,
    less_than_or_equal_to:    0xffffff
  }
  validates! :terminator, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x00,
    less_than_or_equal_to:    0xff
  }, allow_nil: true
  validates! :compressed, inclusion: { in: [true, false] }
  validates! :data, presence: true, length: { minimum: 1 }

  define_model_callbacks :initialize, only: :after

  after_initialize do
    # if neither size nor terminator given, set size to 1 byte
    @size = 1 unless @size || @terminator
    @compressed ||= false
  end

  def initialize(**attributes)
    run_callbacks :initialize do
      super
    end
  end

  def id
    @offset
  end
end
