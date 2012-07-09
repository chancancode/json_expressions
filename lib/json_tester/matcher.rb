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

      if ! matcher.ordered? && ! matcher.unordered?
        matcher.ordered!
      end

      if ! matcher.strict? && ! matcher.forgiving?
        matcher.strict!
      end

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

      if ! matcher.ordered? && ! matcher.unordered?
        matcher.ordered!
      end

      if ! matcher.strict? && ! matcher.forgiving?
        matcher.strict!
      end

      return false if matcher.strict? && matcher.keys.sort != other.keys.sort
      return false if matcher.forgiving? && (matcher.keys-other.keys).empty?
      return false if matcher.ordered? && matcher.keys != other.keys

      matcher.keys.all? { |k| match_json matcher[k], other[k] }
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