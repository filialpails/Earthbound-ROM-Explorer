class TextTable
  include ActiveModel::Model

  validates :name, presence: true
  validates :lengths, presence: true
  validates :replacements, presence: true

  attr_accessor :name, :lengths, :replacements

  def id
    @name
  end
end
