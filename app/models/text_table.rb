class TextTable < ApplicationModel
  validates :name, presence: true
  validates :lengths, presence: true
  validates :replacements, presence: true

  attr_readonly :name, :lengths, :replacements

  def id
    @name
  end
end
