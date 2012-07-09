require 'json_tester'
require 'json_tester/core_extensions'

module JsonTester
  class Matcher
    class << self
      # JsonTester::Matcher.skip_match_on (Array)
      #   An array of classes and modules with undesirable `match` behavior
      #   Default: [ String ]
      attr_accessor :skip_match_on
      JsonTester::Matcher.skip_match_on = [ String ]

      # JsonTester::Matcher.skip_triple_equal_on (Array)
      #   An array of classes and modules with undesirable `===` behavior
      #   Default: []
      attr_accessor :skip_triple_equal_on
      JsonTester::Matcher.skip_triple_equal_on = []

      # JsonTester::Matcher.assume_unordered_arrays (Boolean)
      #   By default, assume arrays are unordered when not specified
      #   Default: true
      attr_accessor :assume_unordered_arrays
      JsonTester::Matcher.assume_unordered_arrays = true

      # JsonTester::Matcher.assume_strict_arrays (Boolean)
      #   By default, reject arrays with extra elements when not specified
      #   Default: true
      attr_accessor :assume_strict_arrays
      JsonTester::Matcher.assume_strict_arrays = true

      # JsonTester::Matcher.assume_unordered_hashes (Boolean)
      #   By default, assume hashes are unordered when not specified
      #   Default: true
      attr_accessor :assume_unordered_hashes
      JsonTester::Matcher.assume_unordered_hashes = true

      # JsonTester::Matcher.assume_strict_hashes (Boolean)
      #   By default, reject hashes with extra keys when not specified
      #   Default: true
      attr_accessor :assume_strict_hashes
      JsonTester::Matcher.assume_strict_hashes = true
    end

    def initialize(json, options = {})
      defaults = {}
      @json = json
      @options = defaults.merge(options)
      @errors = []
    end

    def =~(other)
      match_json(@json, other)
    end

    def match(other)
      self =~ other
    end

    def to_s
      @json.to_s
    end

    private

    def match_json(matcher, other)
      if matcher.is_a? Array
        match_array matcher, other
      elsif matcher.is_a? Hash
        match_hash matcher, other
      elsif matcher.respond_to?(:match) && matchable?(matcher)
        matcher.match(other)
      elsif triple_equable?(matcher)
        matcher === other
      else
        matcher == other
      end
    end

    def match_array(matcher, other)
      return false unless other.is_a? Array

      apply_array_defaults matcher

      return false if matcher.strict? && matcher.size != other.size
      return false if matcher.forgiving? && matcher.size > other.size

      if matcher.ordered?
        matcher.zip(other).all? {|(v1,v2)| match_json(v1,v2)}
      else
        other = other.clone

        matcher.all? do |v1|
          if i = other.find_index {|v2| match_json(v1,v2)}
            other.delete_at i
            true
          else
            false
          end
        end
      end
    end

    def match_hash(matcher, other)
      return false unless other.is_a? Hash

      apply_hash_defaults matcher

      return false if matcher.strict? && matcher.keys.sort != other.keys.sort
      return false if matcher.forgiving? && (matcher.keys-other.keys).empty?
      return false if matcher.ordered? && matcher.keys != other.keys

      matcher.keys.all? { |k| match_json matcher[k], other[k] }
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
        self.class.assume_unordered_arrays ? hash.unordered! : hash.ordered!
      end

      if ! hash.strict? && ! hash.forgiving?
        self.class.assume_strict_arrays ? hash.strict! : hash.forgiving!
      end
    end

    def matchable?(obj)
      if self.class.skip_match_on.include? obj.class
        false
      else
        self.class.skip_match_on.none? { |klass| obj.is_a? klass }
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