class DataBlock < Block
  attr_accessor :entry_sets

  after_initialize do
    @entry_sets ||= []
  end
end
