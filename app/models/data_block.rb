class DataBlock < Block
  validates! :entries, presence: true, length: { minimum: 1 }

  attr_accessor :entries
end
