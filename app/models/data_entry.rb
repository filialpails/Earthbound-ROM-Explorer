class DataEntry < ROMEntry
  validates :entries, presence: true, length: { minimum: 1 }

  attr_readonly :entries
end
