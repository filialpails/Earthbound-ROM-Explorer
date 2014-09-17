# Adds a `memoize` method to the extending object.
module Memoizable
  # Memoizes method named `sym`.
  def memoize(sym)
    old = instance_method(sym)
    define_method(sym) do |*args|
      @memo ||= {}
      @memo[sym] ||= {}
      @memo[sym][args] ||= old.bind(self).call(*args)
    end
  end
end
