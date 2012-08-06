require 'minitest_helper'
require 'json_expressions'
require 'json_expressions/minitest/assertions'

module MiniTest
  class TestAssertions < ::MiniTest::Unit::TestCase
    def setup
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
    end

    def test_assert_json_match
      assert_json_match(@pattern,{
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
      })

      assert_raises(::MiniTest::Assertion) do
        assert_json_match(@pattern,{
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
        })
      end
    end

    def test_refute_json_match
      assert_raises(::MiniTest::Assertion) do
        refute_json_match(@pattern,{
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
        })
      end

      refute_json_match(@pattern,{
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
      })
    end

    def test_json_match_with_json_string
      assert_json_match @pattern, '{"l1_string":"Hello world!","l1_regexp":"0xC0FFEE","l1_boolean":false,"l1_module":1.1,"l1_wildcard":true,"l1_array":["l1: Hello world",1,true,null,false],"l1_object":{"l2_string":"Hi there!","l2_regexp":"1234-5678-1234-5678","l2_boolean":true,"l2_module":[1,2,3,4],"l2_wildcard":"Whatever","l2_array":["l2: Hello world",2,true,null,"Whatever"],"l2_object":{"l3_string":"Good day...","l3_regexp":"","l3_boolean":false,"l3_module":"This is like... inception!","l3_wildcard":null,"l3_array":["l3: Hello world",3,true,null,[]]}}}'
      assert_raises(::MiniTest::Assertion) { assert_json_match @pattern, '{"l1_string":"Hello world!","l1_regexp":"0xC0FFEE","l1_boolean":false,"l1_module":1.1,"l1_wildcard":true,"l1_array":["l1: Hello world",1,true,null,false],"l1_object":{"l2_string":"Hi there!","l2_regexp":"1234-5678-1234-5678","l2_boolean":true,"l2_module":[1,2,3,4],"l2_wildcard":"Whatever","l2_array":["l2: Hello world",2,true,null,"Whatever"],"l2_object":{"l3_string":"Good day...","l3_regexp":"","l3_boolean":false,"l3_module":"This is like... inception!","l3_wildcard":null,"l3_array":["***THIS SHOULD BREAK THINGS***",3,true,null,[]]}}}' }
      refute_json_match @pattern, '{"l1_string":"Hello world!","l1_regexp":"0xC0FFEE","l1_boolean":false,"l1_module":1.1,"l1_wildcard":true,"l1_array":["l1: Hello world",1,true,null,false],"l1_object":{"l2_string":"Hi there!","l2_regexp":"1234-5678-1234-5678","l2_boolean":true,"l2_module":[1,2,3,4],"l2_wildcard":"Whatever","l2_array":["l2: Hello world",2,true,null,"Whatever"],"l2_object":{"l3_string":"Good day...","l3_regexp":"","l3_boolean":false,"l3_module":"This is like... inception!","l3_wildcard":null,"l3_array":["***THIS SHOULD BREAK THINGS***",3,true,null,[]]}}}'
      assert_raises(::MiniTest::Assertion) { refute_json_match @pattern, '{"l1_string":"Hello world!","l1_regexp":"0xC0FFEE","l1_boolean":false,"l1_module":1.1,"l1_wildcard":true,"l1_array":["l1: Hello world",1,true,null,false],"l1_object":{"l2_string":"Hi there!","l2_regexp":"1234-5678-1234-5678","l2_boolean":true,"l2_module":[1,2,3,4],"l2_wildcard":"Whatever","l2_array":["l2: Hello world",2,true,null,"Whatever"],"l2_object":{"l3_string":"Good day...","l3_regexp":"","l3_boolean":false,"l3_module":"This is like... inception!","l3_wildcard":null,"l3_array":["l3: Hello world",3,true,null,[]]}}}' }
    end
  end
end
