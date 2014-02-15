class RecordNotFound < StandardError
end

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

  def self.datastore=(datastore)
    @datastore = datastore
  end

  # ActiveRecord-compatible query methods

  def self.all
    @datastore
  end

  def self.find(id)
    return @datastore.values_at(id) if id.is_a?(Array)
    @datastore[id]
  end

  def self.take(n = nil)
    return @datastore.values.take(n) if n
    @datastore.values.first
  end

  def self.first(n = nil)
    return @datastore.values.first(n) if n
    @datastore.values.first
  end

  def self.last(n = nil)
    return @datastore.values.last(n) if n
    @datastore.values.last
  end

  def self.find_by(**conditions)
    where(**conditions).take
  end

  def self.take!(n)
    take(n) || fail(RecordNotFoundError)
  end

  def self.first!
    first || fail(RecordNotFoundError)
  end

  def self.last!
    last || fail(RecordNotFoundError)
  end

  def self.find_by!(**conditions)
    find_by(**conditions) || fail(RecordNotFoundError)
  end

  def self.where(**conditions)
    return WhereNot.new(@datastore) if conditions.empty?
    @datastore.values.select do |record|
      conditions.all? do |name, value|
        return value.include?(record[name]) if value.is_a?(Enumerable)
        record[name] == value
      end
    end
  end
end

class WhereNot
  def initialize(datastore)
    @datastore = datastore
  end

  def not(**conditions)
    @datastore.values.select do |record|
      conditions.none? do |name, value|
        return value.include?(record[name]) if value.is_a?(Enumerable)
        record[name] == value
      end
    end
  end
end
