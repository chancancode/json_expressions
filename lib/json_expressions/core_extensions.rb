module JsonExpressions
  module Strict; end
  module Forgiving; end
  module Ordered; end
  module Unordered; end

  module CoreExtensions
    def ordered?
      self.is_a? Ordered
    end

    def unordered?
      self.is_a? Unordered
    end

    def ordered!
      if self.unordered?
        raise "cannot mark an unordered #{self.class} as ordered!"
      else
        self.extend Ordered
      end
    end

    def unordered!
      if self.ordered?
        raise "cannot mark an ordered #{self.class} as unordered!"
      else
        self.extend Unordered
      end
    end

    def strict?
      self.is_a? Strict
    end

    def forgiving?
      self.is_a? Forgiving
    end

    def strict!
      if self.forgiving?
        raise "cannot mark a forgiving #{self.class} as strict!"
      else
        self.extend Strict
      end
    end

    def forgiving!
      if self.strict?
        raise "cannot mark a strict #{self.class} as forgiving!"
      else
        self.extend Forgiving
      end
    end
  end
end

class Hash
  include JsonExpressions::CoreExtensions
  alias_method :reject_extra_keys!, :strict!
  alias_method :ignore_extra_keys!, :forgiving!
end

class Array
  include JsonExpressions::CoreExtensions
  alias_method :reject_extra_values!, :strict!
  alias_method :ignore_extra_values!, :forgiving!
end