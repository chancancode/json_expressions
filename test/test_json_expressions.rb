require 'minitest_helper'
require 'json_expressions'

module JsonExpressions
  class TestJsonExpressions < ::MiniTest::Unit::TestCase
    def test_wildcard_matcher_is_a?
      refute WILDCARD_MATCHER.is_a? Object
      refute WILDCARD_MATCHER.is_a? Array
      refute WILDCARD_MATCHER.is_a? Hash
      refute WILDCARD_MATCHER.is_a? Regexp
      refute WILDCARD_MATCHER.is_a? String
    end

    def test_wildcard_matcher_eqaulity
      assert WILDCARD_MATCHER === 1
      assert WILDCARD_MATCHER === 1.1
      assert WILDCARD_MATCHER === 'Hello world!'
      assert WILDCARD_MATCHER === true
      assert WILDCARD_MATCHER === false
      assert WILDCARD_MATCHER === nil
      assert WILDCARD_MATCHER === [1,2,3,4,5]
      assert WILDCARD_MATCHER === {k1: 'v1', k2: 'v2'}

      assert WILDCARD_MATCHER == 1
      assert WILDCARD_MATCHER == 1.1
      assert WILDCARD_MATCHER == 'Hello world!'
      assert WILDCARD_MATCHER == true
      assert WILDCARD_MATCHER == false
      assert WILDCARD_MATCHER == nil
      assert WILDCARD_MATCHER == [1,2,3,4,5]
      assert WILDCARD_MATCHER == {k1: 'v1', k2: 'v2'}
    end

    def test_wildcard_matcher_pattern_matching
      assert WILDCARD_MATCHER =~ 1
      assert WILDCARD_MATCHER =~ 1.1
      assert WILDCARD_MATCHER =~ 'Hello world!'
      assert WILDCARD_MATCHER =~ true
      assert WILDCARD_MATCHER =~ false
      assert WILDCARD_MATCHER =~ nil
      assert WILDCARD_MATCHER =~ [1,2,3,4,5]
      assert WILDCARD_MATCHER =~ {k1: 'v1', k2: 'v2'}

      assert_match WILDCARD_MATCHER, 1
      assert_match WILDCARD_MATCHER, 1.1
      assert_match WILDCARD_MATCHER, 'Hello world!'
      assert_match WILDCARD_MATCHER, true
      assert_match WILDCARD_MATCHER, false
      assert_match WILDCARD_MATCHER, nil
      assert_match WILDCARD_MATCHER, [1,2,3,4,5]
      assert_match WILDCARD_MATCHER, {k1: 'v1', k2: 'v2'}
    end

    def test_wildcard_matcher_inspection
      assert_equal 'WILDCARD_MATCHER', WILDCARD_MATCHER.to_s
      assert_equal 'WILDCARD_MATCHER', WILDCARD_MATCHER.inspect
    end
  end
end