require 'minitest_helper'
require 'json_expressions/minitest'

class TestMiniTestUnit < ::MiniTest::Unit::TestCase
  def test_assertions_defined
    assert_includes ::MiniTest::Assertions.instance_methods, :assert_json_match
    assert_includes ::MiniTest::Assertions.instance_methods, :refute_json_match
  end

  def test_constant_defined
    assert_equal JsonExpressions::WILDCARD_MATCHER.object_id, ::MiniTest::Unit::TestCase::WILDCARD_MATCHER.object_id
  end

  def test_wildcard_matcher_defined
    assert_equal JsonExpressions::WILDCARD_MATCHER.object_id, wildcard_matcher.object_id
  end
end

describe MiniTest::Spec do
  before do
    @pattern = {
      l1_string:   'Hello world!',
      l1_regexp:   /\A0x[0-9a-f]+\z/i,
      l1_boolean:  false,
      l1_module:   Numeric,
      l1_wildcard: wildcard_matcher,
      l1_array:    ['l1: Hello world',1,true,nil,wildcard_matcher],
      l1_object:   {
        l2_string:   'Hi there!',
        l2_regexp:   /\A[0-9]{4}-[0-9]{4}-[0-9]{4}-[0-9]{4}\z/i,
        l2_boolean:  true,
        l2_module:   Enumerable,
        l2_wildcard: wildcard_matcher,
        l2_array:    ['l2: Hello world',2,true,nil,wildcard_matcher],
        l2_object:   {
          l3_string:   'Good day...',
          l3_regexp:   /\A.*\z/,
          l3_boolean:  false,
          l3_module:   String,
          l3_wildcard: wildcard_matcher,
          l3_array:    ['l3: Hello world',3,true,nil,wildcard_matcher],
        }
      }
    }

    @matching_json = {
      l1_string:   'Hello world!',
      l1_regexp:   '0xC0FFEE',
      l1_boolean:  false,
      l1_module:   1.1,
      l1_wildcard: true,
      l1_array:    ['l1: Hello world',1,true,nil,false],
      l1_object:   {
        l2_string:   'Hi there!',
        l2_regexp:   '1234-5678-1234-5678',
        l2_boolean:  true,
        l2_module:   [1,2,3,4],
        l2_wildcard: 'Whatever',
        l2_array:    ['l2: Hello world',2,true,nil,'Whatever'],
        l2_object:   {
          l3_string:   'Good day...',
          l3_regexp:   '',
          l3_boolean:  false,
          l3_module:   'This is like... inception!',
          l3_wildcard: nil,
          l3_array:    ['l3: Hello world',3,true,nil,[]]
        }
      }
    }

    @non_matching_json = {
      l1_string:   'Hello world!',
      l1_regexp:   '0xC0FFEE',
      l1_boolean:  false,
      l1_module:   1.1,
      l1_wildcard: true,
      l1_array:    ['l1: Hello world',1,true,nil,false],
      l1_object:   {
        l2_string:   'Hi there!',
        l2_regexp:   '1234-5678-1234-5678',
        l2_boolean:  true,
        l2_module:   [1,2,3,4],
        l2_wildcard: 'Whatever',
        l2_array:    ['l2: Hello world',2,true,nil,'Whatever'],
        l2_object:   {
          l3_string:   'Good day...',
          l3_regexp:   '',
          l3_boolean:  false,
          l3_module:   'This is like... inception!',
          l3_wildcard: nil,
          l3_array:    ['***THIS SHOULD BREAK THINGS***',3,true,nil,[]]
        }
      }
    }
  end

  describe '#must_match_json_expression' do
    it 'should pass when the json matches the pattern' do
      @matching_json.must_match_json_expression @pattern
    end

    it 'should raise an exception when the json does not match the pattern' do
      assert_raises(::MiniTest::Assertion) do
        @non_matching_json.must_match_json_expression @pattern
      end
    end
  end

  describe '#wont_match_json_expression' do
    it 'should pass when the json does not match the pattern' do
      @non_matching_json.wont_match_json_expression @pattern
    end

    it 'should raise an exception when the json matches the pattern' do
      assert_raises(::MiniTest::Assertion) do
        @matching_json.wont_match_json_expression @pattern
      end
    end
  end

  it 'should also work with strings' do
    @matching_json_string = '{"l1_string":"Hello world!","l1_regexp":"0xC0FFEE","l1_boolean":false,"l1_module":1.1,"l1_wildcard":true,"l1_array":["l1: Hello world",1,true,null,false],"l1_object":{"l2_string":"Hi there!","l2_regexp":"1234-5678-1234-5678","l2_boolean":true,"l2_module":[1,2,3,4],"l2_wildcard":"Whatever","l2_array":["l2: Hello world",2,true,null,"Whatever"],"l2_object":{"l3_string":"Good day...","l3_regexp":"","l3_boolean":false,"l3_module":"This is like... inception!","l3_wildcard":null,"l3_array":["l3: Hello world",3,true,null,[]]}}}'
    @non_matching_json_string =  '{"l1_string":"Hello world!","l1_regexp":"0xC0FFEE","l1_boolean":false,"l1_module":1.1,"l1_wildcard":true,"l1_array":["l1: Hello world",1,true,null,false],"l1_object":{"l2_string":"Hi there!","l2_regexp":"1234-5678-1234-5678","l2_boolean":true,"l2_module":[1,2,3,4],"l2_wildcard":"Whatever","l2_array":["l2: Hello world",2,true,null,"Whatever"],"l2_object":{"l3_string":"Good day...","l3_regexp":"","l3_boolean":false,"l3_module":"This is like... inception!","l3_wildcard":null,"l3_array":["***THIS SHOULD BREAK THINGS***",3,true,null,[]]}}}'

    @matching_json_string.must_match_json_expression @pattern
    assert_raises(::MiniTest::Assertion) { @non_matching_json.must_match_json_expression @pattern }

    @non_matching_json_string.wont_match_json_expression @pattern
    assert_raises(::MiniTest::Assertion) { @matching_json.wont_match_json_expression @pattern }
  end
end
