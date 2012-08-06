require 'minitest/unit'
require 'minitest/spec'
require 'json_expressions'
require 'json_expressions/minitest/assertions'

# module MiniTest::Assertions
#   include JsonExpressions::MiniTest::Assertions
# end

class MiniTest::Unit::TestCase
  WILDCARD_MATCHER = JsonExpressions::WILDCARD_MATCHER
end

class MiniTest::Spec
  WILDCARD_MATCHER = JsonExpressions::WILDCARD_MATCHER
end

Object.infect_an_assertion :assert_json_match, :must_match_json
Object.infect_an_assertion :refute_json_match, :wont_match_json
