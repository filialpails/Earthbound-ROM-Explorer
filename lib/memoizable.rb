module Memoizable
  module ClassMethods
    def memoize(sym)
      old = instance_method(sym)
      define_method(sym) do |*args|
        _memo(sym, old, *args)
      end
    end
  end

  def self.included(mod)
    mod.extend(ClassMethods)
  end

  def _memo(sym, old, *args)
    @memo ||= {}
    @memo[sym] ||= {}
    @memo[sym][args] ||= old.bind(self).call(*args)
  end
end
