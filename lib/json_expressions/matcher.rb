require 'json_expressions'
require 'json_expressions/core_extensions'

module JsonExpressions
  class Matcher
    class << self
      # JsonExpressions::Matcher.skip_triple_equal_on (Array)
      #   An array of classes and modules with undesirable `===` behavior
      #   Default: []
      attr_accessor :skip_triple_equal_on
      JsonExpressions::Matcher.skip_triple_equal_on = []

      # JsonExpressions::Matcher.assume_unordered_arrays (Boolean)
      #   By default, assume arrays are unordered when not specified
      #   Default: true
      attr_accessor :assume_unordered_arrays
      JsonExpressions::Matcher.assume_unordered_arrays = false

      # JsonExpressions::Matcher.assume_strict_arrays (Boolean)
      #   By default, reject arrays with extra elements when not specified
      #   Default: true
      attr_accessor :assume_strict_arrays
      JsonExpressions::Matcher.assume_strict_arrays = true

      # JsonExpressions::Matcher.assume_unordered_hashes (Boolean)
      #   By default, assume hashes are unordered when not specified
      #   Default: true
      attr_accessor :assume_unordered_hashes
      JsonExpressions::Matcher.assume_unordered_hashes = true

      # JsonExpressions::Matcher.assume_strict_hashes (Boolean)
      #   By default, reject hashes with extra keys when not specified
      #   Default: true
      attr_accessor :assume_strict_hashes
      JsonExpressions::Matcher.assume_strict_hashes = true
    end

    attr_reader :last_error
    attr_reader :captures

    def initialize(json, options = {})
      defaults = {}
      @json = json
      @options = defaults.merge(options)
      reset!
    end

    def =~(other)
      reset!
      match_json('(JSON ROOT)', @json, other)
    end

    def match(other)
      self =~ other
    end

    def to_s
      @json.to_s
    end

    private

    def reset!
      @last_errot = nil
      @captures   = {}
    end

    def match_json(path, matcher, other)
      if matcher.is_a? Symbol
        capture path, matcher, other
      elsif matcher.is_a? Array
        match_array path, matcher, other
      elsif matcher.is_a? Hash
        match_hash path, matcher, other
      elsif triple_equable?(matcher)
        match_obj path, matcher, other, :===
      else
        match_obj path, matcher, other, :==
      end
    end

    def capture(path, name, value)
      if @captures.key? name
        if match_json nil, @captures[name], value
          true
        else
          set_last_error path, "At %path%: expected capture with key #{name.inspect} and value #{@captures[name]} to match #{value.inspect}"
          false
        end
      else
        @captures[name] = value
        true
      end
    end

    def match_obj(path, matcher, other, meth)
      if matcher.__send__ meth, other
        true
      else
        set_last_error path, "At %path%: expected #{matcher.inspect} to match #{other.inspect}"
        return false
      end
    end

    def match_array(path, matcher, other)
      unless other.is_a? Array
        set_last_error path, "%path% is not an array"
        return false
      end

      apply_array_defaults matcher

      if matcher.size > other.size
        set_last_error path, "%path% contains too few elements (#{matcher.size} expected but was #{other.size})"
        return false
      end

      if matcher.strict? && matcher.size < other.size
        set_last_error path, "%path% contains too many elements (#{matcher.size} expected but was #{other.size})"
        return false
      end

      if matcher.ordered?
        matcher.zip(other).each_with_index { |(v1,v2),i| return false unless match_json(make_path(path,i), v1, v2) }
      else
        other = other.clone

        matcher.all? do |v1|
          if i = other.find_index { |v2| match_json(nil, v1, v2) }
            other.delete_at i
            true
          else
            set_last_error path, "%path% does not contain an element matching #{v1.inspect}"
            false
          end
        end
      end
    end

    def match_hash(path, matcher, other)
      unless other.is_a? Hash
        set_last_error path, "%path% is not a hash"
        return false
      end

      apply_hash_defaults matcher

      missing_keys = matcher.keys.map(&:to_s) - other.keys.map(&:to_s)
      extra_keys   = other.keys.map(&:to_s) - matcher.keys.map(&:to_s)

      unless missing_keys.empty?
        set_last_error path, "%path% does not contain the key #{missing_keys.first.to_s}"
        return false
      end

      if matcher.strict? && ! extra_keys.empty?
        set_last_error path, "%path% contains an extra key #{extra_keys.first.to_s}"
        return false
      end

      if matcher.ordered? && matcher.keys != other.keys
        set_last_error path, "Incorrect key-ordering at %path% (#{matcher.keys.map(&:to_s).inspect} expected but was #{other.keys.map(&:to_s).inspect})"
        return false
      end

      matcher.keys.all? { |k| match_json make_path(path,k), matcher[k] , other[k.to_s] || other[k.to_sym] }
    end

    def set_last_error(path, message)
      @last_error = message.gsub('%path%',path) if path
    end

    def make_path(path, segment)
      if path
        segment.is_a?(Fixnum) ? path + "[#{segment}]" : path + ".#{segment.to_s}"
      end
    end

    def apply_array_defaults(array)
      if ! array.ordered? && ! array.unordered?
        self.class.assume_unordered_arrays ? array.unordered! : array.ordered!
      end

      if ! array.strict? && ! array.forgiving?
        self.class.assume_strict_arrays ? array.strict! : array.forgiving!
      end
    end

    def apply_hash_defaults(hash)
      if ! hash.ordered? && ! hash.unordered?
        self.class.assume_unordered_hashes ? hash.unordered! : hash.ordered!
      end

      if ! hash.strict? && ! hash.forgiving?
        self.class.assume_strict_hashes ? hash.strict! : hash.forgiving!
      end
    end

    def triple_equable?(obj)
      if self.class.skip_triple_equal_on.include? obj.class
        false
      else
        self.class.skip_triple_equal_on.none? { |klass| obj.is_a? klass }
      end
    end
  end
end