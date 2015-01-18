class DataEntry
  include ActiveModel::Model

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
  validates! :compressed, inclusion: { in: [true, false] }, allow_nil: true
  validates! :data, presence: true, length: { minimum: 1 }

  attr_accessor :size, :terminator, :name, :compressed, :data

  define_model_callbacks :initialize, only: :after

  after_initialize do
    @compressed ||= false
  end

  def initialize(**attributes)
    run_callbacks :initialize do
      super
    end
  end
end
