require 'minitest_helper'
require 'json_tester'
require 'json_tester/minitest/unit/helpers'

module JsonTester
  module MiniTest
    module Unit
      class TestHelpers < ::MiniTest::Unit::TestCase
        include Helpers

        def setup
          @pattern = {
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

        def test_assert_json_match
          # TODO: actually test its behavior
          assert_json_match(@pattern,{
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
          })
        end

        def test_json_match_with_json_string
          assert_json_match @pattern, '{"l1_string":"Hello world!","l1_regexp":"0xC0FFEE","l1_module":1.1,"l1_wildcard":true,"l1_array":["l1: Hello world",1,true,null,false],"l1_object":{"l2_string":"Hi there!","l2_regexp":"1234-5678-1234-5678","l2_module":[1,2,3,4],"l2_wildcard":"Whatever","l2_array":["l2: Hello world",2,true,null,"Whatever"],"l2_object":{"l3_string":"Good day...","l3_regexp":"","l3_module":"This is like... inception!","l3_wildcard":null,"l3_array":["l3: Hello world",3,true,null,[]]}}}'
        end
      end
    end
  end
end