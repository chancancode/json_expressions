require 'minitest_helper'
require 'json_expressions/matcher'

module JsonExpressions
  class TestMatcher < ::MiniTest::Unit::TestCase
    def setup
      @simple_object = {
        integer: 1,
        float:   1.1,
        string:  'Hello world!',
        boolean: false,
        array:   [1,2,3],
        object:  {'key1' => 'value1','key2' => 'value2'},
        null:    nil,
      }

      @simple_array  = [
        1,
        1.1,
        'Hello world!',
        false,
        [1,2,3],
        {key1: 'value1', key2: 'value2'},
        nil
      ]

      @complex_pattern = {
        l1_string:    'Hello world!',
        l1_regexp:    /\A0x[0-9a-f]+\z/i,
        l1_boolean:   false,
        l1_module:    Numeric,
        l1_wildcard:  WILDCARD_MATCHER,
        l1_array:     ['l1: Hello world',1,true,nil,WILDCARD_MATCHER],
        l1_object:    {
          l2_string:    'Hi there!',
          l2_regexp:    /\A[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}\z/i,
          l2_boolean:   true,
          l2_module:    Enumerable,
          l2_wildcard:  WILDCARD_MATCHER,
          l2_array:     ['l2: Hello world',2,true,nil,WILDCARD_MATCHER],
          l2_object:    {
            l3_string:    'Good day...',
            l3_regexp:    /\A.*\z/,
            l3_boolean:   false,
            l3_module:    String,
            l3_wildcard:  WILDCARD_MATCHER,
            l3_array:     ['l3: Hello world',3,true,nil,WILDCARD_MATCHER],
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

    def test_match_arrays_ordered
      assert_match Matcher.new(@simple_array.ordered!), @simple_array
      refute_match Matcher.new(@simple_array.ordered!), @simple_array.reverse
      refute_match Matcher.new(@simple_array.ordered!), []
    end

    def test_match_arrays_unordered
      assert_match Matcher.new(@simple_array.unordered!), @simple_array
      assert_match Matcher.new(@simple_array.unordered!), @simple_array.reverse
      refute_match Matcher.new(@simple_array.unordered!), []
    end

    def test_match_arrays_strict
      assert_match Matcher.new(@simple_array.strict!), @simple_array
      refute_match Matcher.new(@simple_array.strict!), @simple_array + ['extra']
      refute_match Matcher.new(@simple_array.strict!), @simple_array[1..-1]
    end

    def test_match_arrays_forgiving
      assert_match Matcher.new(@simple_array.forgiving!), @simple_array
      assert_match Matcher.new(@simple_array.forgiving!), @simple_array + ['extra']
      refute_match Matcher.new(@simple_array.forgiving!), @simple_array[1..-1]
    end

    def test_match_objects
      assert_match Matcher.new({}), {}
      assert_match Matcher.new(@simple_object), @simple_object
      refute_match Matcher.new(@simple_object), {}
      refute_match Matcher.new({}), @simple_object
    end

    def test_match_objects_ordered
      reversed = @simple_object.reverse_each.inject({}){ |hash,(k,v)| hash[k] = v; hash }
      assert_match Matcher.new(@simple_object.ordered!), @simple_object
      refute_match Matcher.new(@simple_object.ordered!), reversed
      refute_match Matcher.new(@simple_object.ordered!), {}
    end

    def test_match_objects_unordered
      reversed = @simple_object.reverse_each.inject({}){ |hash,(k,v)| hash[k] = v; hash }
      assert_match Matcher.new(@simple_object.unordered!), @simple_object
      assert_match Matcher.new(@simple_object.unordered!), reversed
      refute_match Matcher.new(@simple_object.unordered!), {}
    end

    def test_match_objects_strict
      assert_match Matcher.new(@simple_object.strict!), @simple_object
      refute_match Matcher.new(@simple_object.strict!), @simple_object.merge({extra: 'stuff'})
      refute_match Matcher.new(@simple_object.strict!), @simple_object.clone.delete_if {|key| key == :integer}
    end

    def test_match_objects_forgiving
      assert_match Matcher.new(@simple_object.forgiving!), @simple_object
      assert_match Matcher.new(@simple_object.forgiving!), @simple_object.merge({extra: 'stuff'})
      refute_match Matcher.new(@simple_object.forgiving!), @simple_object.clone.delete_if {|key| key == :integer}
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
      assert_match Matcher.new(WILDCARD_MATCHER), {key1: 'value1',key2: 'value2'}
      assert_match Matcher.new(WILDCARD_MATCHER), nil
    end

    def test_capture
      m = Matcher.new({key1: :capture_me})
      assert_match m, {key1: 'value1'}
      assert_equal 'value1', m.captures[:capture_me]
    end

    def test_match_capture
      m = Matcher.new({key1: :capture_me, key2: :capture_me})
      m =~ {key1: 'value1', key2: 'value1'}
      assert_match m, {key1: 'value1', key2: 'value1'}
      refute_match m, {key1: 'value1', key2: 'value2'}
    end

    def test_match_recursive
      positive_target = {
        l1_string:    'Hello world!',
        l1_regexp:    '0xC0FFEE',
        l1_boolean:   false,
        l1_module:    1.1,
        l1_wildcard:  true,
        l1_array:     ['l1: Hello world',1,true,nil,false],
        l1_object:    {
          l2_string:    'Hi there!',
          l2_regexp:    '1234-5678-1234-5678',
          l2_boolean:   true,
          l2_module:    [1,2,3,4],
          l2_wildcard:  'Whatever',
          l2_array:     ['l2: Hello world',2,true,nil,'Whatever'],
          l2_object:    {
            l3_string:    'Good day...',
            l3_regexp:    '',
            l3_boolean:   false,
            l3_module:    'This is like... inception!',
            l3_wildcard:  nil,
            l3_array:     ['l3: Hello world',3,true,nil,[]]
          }
        }
      }

      negative_target = {
        l1_string:    'Hello world!',
        l1_regexp:    '0xC0FFEE',
        l1_boolean:   false,
        l1_module:    1.1,
        l1_wildcard:  true,
        l1_array:     ['l1: Hello world',1,true,nil,false],
        l1_object:    {
          l2_string:    'Hi there!',
          l2_regexp:    '1234-5678-1234-5678',
          l2_boolean:   true,
          l2_module:    [1,2,3,4],
          l2_wildcard:  'Whatever',
          l2_array:     ['l2: Hello world',2,true,nil,'Whatever'],
          l2_object:    {
            l3_string:    'Good day...',
            l3_regexp:    '',
            l3_boolean:   false,
            l3_module:    'This is like... inception!',
            l3_wildcard:  nil,
            l3_array:     ['***THIS SHOULD BREAK THINGS***',3,true,nil,[]]
          }
        }
      }

      assert_match Matcher.new(@complex_pattern), positive_target
      refute_match Matcher.new(@complex_pattern), negative_target
    end

    def test_error_not_match
      m = Matcher.new('Hello world!')
      m =~ nil
      assert_equal 'At (JSON ROOT): expected "Hello world!" to match nil', m.last_error
    end

    def test_error_not_match_capture
      m = Matcher.new({key1: :capture_me, key2: :capture_me})
      m =~ {key1: 'value1', key2: nil}
      assert_equal 'At (JSON ROOT).key2: expected capture with key :capture_me and value value1 to match nil', m.last_error
    end

    def test_error_not_an_array
      m = Matcher.new([1,2,3,4,5])
      m =~ nil
      assert_equal '(JSON ROOT) is not an array', m.last_error
    end

    def test_error_undersized_array
      m = Matcher.new([1,2,3,4,5])
      m =~ [1,2,3,4]
      assert_equal '(JSON ROOT) contains too few elements (5 expected but was 4)', m.last_error
    end

    def test_error_oversized_array
      m = Matcher.new([1,2,3,4,5].strict!)
      m =~ [1,2,3,4,5,6]
      assert_equal '(JSON ROOT) contains too many elements (5 expected but was 6)', m.last_error
    end

    def test_error_array_ordered_no_match
      m = Matcher.new([1,2,3,4,5].ordered!)
      m =~ [1,2,3,4,6]
      assert_equal 'At (JSON ROOT)[4]: expected 5 to match 6', m.last_error
    end

    def test_error_array_unordered_no_match
      m = Matcher.new([1,2,3,4,5].unordered!)
      m =~ [1,2,3,4,6]
      assert_equal '(JSON ROOT) does not contain an element matching 5', m.last_error
    end

    def test_error_not_a_hash
      m = Matcher.new({key1: 'value1', key2: 'value2'})
      m =~ nil
      assert_equal '(JSON ROOT) is not a hash', m.last_error
    end

    def test_error_hash_missing_key
      m = Matcher.new({key1: 'value1', key2: 'value2'})
      m =~ {key1:  'value1'}
      assert_equal '(JSON ROOT) does not contain the key key2', m.last_error
    end

    def test_error_hash_extra_key
      m = Matcher.new({key1: 'value1', key2: 'value2'}.strict!)
      m =~ {key1: 'value1', key2: 'value2', key3: 'value3'}
      assert_equal '(JSON ROOT) contains an extra key key3', m.last_error
    end

    def test_error_hash_ordering
      m = Matcher.new({key1: 'value1', key2: 'value2'}.ordered!)
      m =~ {key2: 'value2', key1: 'value1'}
      assert_equal 'Incorrect key-ordering at (JSON ROOT) (["key1", "key2"] expected but was ["key2", "key1"])', m.last_error
    end

    def test_error_hash_no_match
      m = Matcher.new({key1: 'value1', key2: 'value2'})
      m =~ {key1: 'value1', key2: nil}
      assert_equal 'At (JSON ROOT).key2: expected "value2" to match nil', m.last_error
    end

    def test_error_path
      m = Matcher.new({l1:{l2:[nil,nil,{l3:[nil,nil,nil,'THIS'].ordered!}].ordered!}})
      m =~ {l1:{l2:[nil,nil,{l3:[nil,nil,nil,'THAT']}]}}
      assert_equal 'At (JSON ROOT).l1.l2[2].l3[3]: expected "THIS" to match "THAT"', m.last_error
    end

    def test_inspection
      test_cases = [ {}, @simple_object, [], @simple_array, @complex_pattern ]

      test_cases.each do |e|
        assert_equal e.to_s, Matcher.new(e).to_s
        assert_equal e.inspect, Matcher.new(e).inspect
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

    def test_assume_unordered_arrays
      old_assume_unordered_arrays = Matcher.assume_unordered_arrays

      begin
        Matcher.assume_unordered_arrays = true
        assert_match Matcher.new(@simple_array.clone), @simple_array.reverse
        Matcher.assume_unordered_arrays = false
        refute_match Matcher.new(@simple_array.clone), @simple_array.reverse
      ensure
        Matcher.assume_unordered_arrays = old_assume_unordered_arrays
      end
    end

    def test_assume_unordered_arrays
      old_assume_unordered_arrays = Matcher.assume_unordered_arrays

      begin
        Matcher.assume_unordered_arrays = true
        assert_match Matcher.new(@simple_array.clone), @simple_array.reverse
        Matcher.assume_unordered_arrays = false
        refute_match Matcher.new(@simple_array.clone), @simple_array.reverse
      ensure
        Matcher.assume_unordered_arrays = old_assume_unordered_arrays
      end
    end

    def test_assume_strict_arrays
      old_assume_strict_arrays = Matcher.assume_strict_arrays

      begin
        Matcher.assume_strict_arrays = true
        refute_match Matcher.new(@simple_array.clone), @simple_array + ['extra']
        Matcher.assume_strict_arrays = false
        assert_match Matcher.new(@simple_array.clone), @simple_array + ['extra']
      ensure
        Matcher.assume_strict_arrays = old_assume_strict_arrays
      end
    end

    def test_assume_unordered_hashes
      old_assume_unordered_hashes = Matcher.assume_unordered_hashes

      begin
        reversed = @simple_object.reverse_each.inject({}){ |hash,(k,v)| hash[k] = v; hash }

        Matcher.assume_unordered_hashes = true
        assert_match Matcher.new(@simple_object.clone), reversed
        Matcher.assume_unordered_hashes = false
        refute_match Matcher.new(@simple_object.clone), reversed
      ensure
        Matcher.assume_unordered_hashes = old_assume_unordered_hashes
      end
    end

    def test_assume_strict_hashes
      old_assume_strict_hashes = Matcher.assume_strict_hashes

      begin
        Matcher.assume_strict_hashes = true
        refute_match Matcher.new(@simple_object.clone), @simple_object.merge({extra: 'stuff'})
        Matcher.assume_strict_hashes = false
        assert_match Matcher.new(@simple_object.clone), @simple_object.merge({extra: 'stuff'})
      ensure
        Matcher.assume_strict_hashes = old_assume_strict_hashes
      end
    end

    def test_hash_with_indifferent_access
      assert_match Matcher.new({a:1,b:false,c:nil}), {a:1,b:false,c:nil}
      assert_match Matcher.new({'a'=>1,'b'=>false,'c'=>nil}), {a:1,b:false,c:nil}
      assert_match Matcher.new({a:1,b:false,c:nil}), {'a'=>1,'b'=>false,'c'=>nil}
      assert_match Matcher.new({'a'=>1,'b'=>false,'c'=>nil}), {'a'=>1,'b'=>false,'c'=>nil}
    end

    private

    def jsonize()
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