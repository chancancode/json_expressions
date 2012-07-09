require 'minitest_helper'
require 'json_tester/matcher'

module JsonTester
  class TestMatcher < MiniTest::Unit::TestCase
    def setup
      @simple_object = {
        'integer' => 1,
        'float'   => 1.1,
        'string'  => 'Hello world!',
        'boolean' => true,
        'array'   => [1,2,3],
        'object'  => {'key1' => 'value1','key2' => 'value2'},
        'null'    => nil,
      }

      @simple_array  = [
        1,
        1.1,
        'Hello world!',
        true,
        [1,2,3],
        {'key1' => 'value1','key2' => 'value2'},
        nil
      ]

      @complex_pattern = pattern = {
        'l1_string'   => 'Hello world!',
        'l1_regexp'   => /\A0x[0-9a-f]+\z/i,
        'l1_module'   => Numeric,
        'l1_wildcard' => WILDCARD_MATCHER,
        'l1_array'    => ['l1: Hello world',1,true,nil,WILDCARD_MATCHER],
        'l1_object'   => {
          'l2_string'   => 'Hi there!',
          'l2_regexp'   => /\A[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}\z/i,
          'l2_module'   => Enumerable,
          'l2_wildcard' => WILDCARD_MATCHER,
          'l2_array'    => ['l2: Hello world',2,true,nil,WILDCARD_MATCHER],
          'l2_object'   => {
            'l3_string'   => 'Good day...',
            'l3_regexp'   => /\A.*\z/,
            'l3_module'   => String,
            'l3_wildcard' => WILDCARD_MATCHER,
            'l3_array'    => ['l3: Hello world',3,true,nil,WILDCARD_MATCHER],
          }
        }
      }
    end

    def test_match_numbers
      assert_match Matcher.new(1), 1
      assert_match Matcher.new(1.1), 1.1
      assert_match Matcher.new(1.0), 1
      assert_match Matcher.new(1), 1.0
      refute_match Matcher.new(1.1), 1
      refute_match Matcher.new(1), 1.1
    end

    def test_match_strings
      assert_match Matcher.new('Hello world!'), 'Hello world!'
      refute_match Matcher.new('Hello world!'), ''
      refute_match Matcher.new(''), 'Hello world!'
      refute_match Matcher.new('Hello world!'), 'HELLO WORLD!'
    end

    def test_match_booleans
      assert_match Matcher.new(true), true
      assert_match Matcher.new(false), false
      refute_match Matcher.new(true), false
      refute_match Matcher.new(false), true
    end

    def test_match_arrays
      assert_match Matcher.new([]), []
      assert_match Matcher.new(@simple_array), @simple_array
      refute_match Matcher.new(@simple_array), []
      refute_match Matcher.new([]), @simple_array
    end

    def test_match_objects
      assert_match Matcher.new({}), {}
      assert_match Matcher.new(@simple_object), @simple_object
      refute_match Matcher.new(@simple_object), {}
      refute_match Matcher.new({}), @simple_object
    end

    def test_match_nil
      assert_match Matcher.new(nil), nil
    end

    def test_match_regexp
      assert_match Matcher.new(/\A0x[0-9a-f]+\z/i), '0xC0FFEE'
      refute_match Matcher.new(/\A0x[0-9a-f]+\z/i), 'Hello world!'
    end

    def test_match_modules
      assert_match Matcher.new(String), 'Hello world!'
      assert_match Matcher.new(Numeric), 1
      assert_match Matcher.new(Numeric), 1.1
      assert_match Matcher.new(Enumerable), [1,2,3]
      assert_match Matcher.new(Enumerable), (1..10)
      refute_match Matcher.new(String), nil
      refute_match Matcher.new(Numeric), {a:1}
      refute_match Matcher.new(Enumerable), Time.now
    end

    def test_match_wildcard
      assert_match Matcher.new(WILDCARD_MATCHER), 1
      assert_match Matcher.new(WILDCARD_MATCHER), 1.1
      assert_match Matcher.new(WILDCARD_MATCHER), 'Hello world!'
      assert_match Matcher.new(WILDCARD_MATCHER), true
      assert_match Matcher.new(WILDCARD_MATCHER), false
      assert_match Matcher.new(WILDCARD_MATCHER), [1,2,3]
      assert_match Matcher.new(WILDCARD_MATCHER), {'key1' => 'value1','key2' => 'value2'}
      assert_match Matcher.new(WILDCARD_MATCHER), nil
    end

    def test_match_recursive
      positive_target = {
        'l1_string'   => 'Hello world!',
        'l1_regexp'   => '0xC0FFEE',
        'l1_module'   => 1.1,
        'l1_wildcard' => true,
        'l1_array'    => ['l1: Hello world',1,true,nil,false],
        'l1_object'   => {
          'l2_string'   => 'Hi there!',
          'l2_regexp'   => '1234-5678-1234-5678',
          'l2_module'   => [1,2,3,4],
          'l2_wildcard' => 'Whatever',
          'l2_array'    => ['l2: Hello world',2,true,nil,'Whatever'],
          'l2_object'   => {
            'l3_string'   => 'Good day...',
            'l3_regexp'   => '',
            'l3_module'   => 'This is like... inception!',
            'l3_wildcard' => nil,
            'l3_array'    => ['l3: Hello world',3,true,nil,[]]
          }
        }
      }

      negative_target = {
        'l1_string'   => 'Hello world!',
        'l1_regexp'   => '0xC0FFEE',
        'l1_module'   => 1.1,
        'l1_wildcard' => true,
        'l1_array'    => ['l1: Hello world',1,true,nil,false],
        'l1_object'   => {
          'l2_string'   => 'Hi there!',
          'l2_regexp'   => '1234-5678-1234-5678',
          'l2_module'   => [1,2,3,4],
          'l2_wildcard' => 'Whatever',
          'l2_array'    => ['l2: Hello world',2,true,nil,'Whatever'],
          'l2_object'   => {
            'l3_string'   => 'Good day...',
            'l3_regexp'   => '',
            'l3_module'   => 'This is like... inception!',
            'l3_wildcard' => nil,
            'l3_array'    => ['***THIS SHOULD BREAK THINGS***',3,true,nil,[]]
          }
        }
      }

      assert_match Matcher.new(@complex_pattern), positive_target
      refute_match Matcher.new(@complex_pattern), negative_target
    end

    def test_inspection
      test_cases = [ {}, @simple_object, [], @simple_array, @complex_pattern ]

      test_cases.each do |e|
        assert_equal e.to_s, Matcher.new(e).to_s
        assert_equal e.inspect, Matcher.new(e).inspect
      end
    end

    def test_skip_match
      old_skip_match_on = Matcher.skip_match_on

      Matcher.skip_match_on = [String, Numeric, Enumerable]

      begin
        publicize_method(Matcher, :matchable?) do
          matcher = Matcher.new(nil)
          refute matcher.matchable? 'Hello world!'
          refute matcher.matchable? 1
          refute matcher.matchable? 1.1
          refute matcher.matchable? [1,2,3]
          refute matcher.matchable? (1..10)
          assert matcher.matchable? true
          assert matcher.matchable? nil
          assert matcher.matchable? Time.now
        end
      ensure
        Matcher.skip_match_on = old_skip_match_on
      end
    end

    def test_skip_triple_equal
      old_skip_triple_equal_on = Matcher.skip_triple_equal_on

      Matcher.skip_triple_equal_on = [String, Numeric, Enumerable]

      begin
        publicize_method(Matcher, :triple_equable?) do
          matcher = Matcher.new(nil)
          refute matcher.triple_equable? 'Hello world!'
          refute matcher.triple_equable? 1
          refute matcher.triple_equable? 1.1
          refute matcher.triple_equable? [1,2,3]
          refute matcher.triple_equable? (1..10)
          assert matcher.triple_equable? true
          assert matcher.triple_equable? nil
          assert matcher.triple_equable? Time.now
        end
      ensure
        Matcher.skip_triple_equal_on = old_skip_triple_equal_on
      end
    end

    private

    def replace_constant(source, const, new_value, &block)
      replace_constants(source, [[const, new_value]], &block)
    end

    def replace_constants(source, pairs, &block)
      replaced = []

      begin
        pairs.each { |(c,v)| replaced << change_constant(source,c,v) }
        yield
      ensure
        replaced.each { |(c,v)| change_constant(source,c,v) }
      end
    end

    def change_constant(source, const, new_value)
      old_value = source.const_get const
      source.__send__ :remove_const, const
      source.const_set const, new_value
      [const, old_value]
    end

    def publicize_method(source, meth, &block)
      publicize_methods(source, [meth], &block)
    end

    def publicize_methods(source, pairs, &block)
      changed = []

      begin
        pairs.each { |meth| change_visibility(source, meth, :public) }
        yield
      ensure
        changed.each { |meth,viz| change_visibility(source, meth, viz) }
      end
    end

    def change_visibility(source, meth, viz)
      old_viz = if source.public_method_defined? meth
        :public
      elsif source.private_method_defined? meth
        :private
      elsif source.protected_method_defined? meth
        :protected
      else
        # call the method to trigger a NoMethodError
        source.__send__ meth
      end
      source.__send__ viz, meth
      [meth, old_viz]
    end
  end
end