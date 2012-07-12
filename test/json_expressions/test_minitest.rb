require 'minitest_helper'
require 'json_expressions/minitest'

class TestMiniTest < ::MiniTest::Unit::TestCase
  def test_minitest_unit
    assert_includes ::MiniTest::Unit::TestCase.ancestors, JsonExpressions::MiniTest::Unit::Helpers
    assert_equal JsonExpressions::WILDCARD_MATCHER.object_id, ::MiniTest::Unit::TestCase::WILDCARD_MATCHER.object_id
  end
end