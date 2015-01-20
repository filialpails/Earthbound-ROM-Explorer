class DataEntrySet
  include ActiveModel::Model

  attr_accessor :size, :entries

  validates! :size, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 0x000001,
    less_than_or_equal_to:    0xffffff
  }

  define_model_callbacks :initialize, only: :after

  after_initialize do
    @entries ||= []
  end

  def initialize(**attributes)
    run_callbacks :initialize do
      super
    end
  end
end
