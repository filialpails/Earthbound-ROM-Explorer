class ApplicationModel
  include ActiveModel::Model

  def initialize(**attributes)
    attributes.each do |attr, value|
      send(:"#{attr}=", value)
    end
  end

  def self.attr_readonly(*attrs)
    attr_accessor *attrs
    private *(attrs.map {|attr| :"#{attr}=" })
  end
end
