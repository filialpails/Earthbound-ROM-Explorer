class DataBlock < Block
  attr_accessor :entries

  after_initialize do
    @entries ||= []
  end
end
