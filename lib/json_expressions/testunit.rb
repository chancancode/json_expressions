require 'test/unit'
require 'json_expressions'
require 'json_expressions/test/unit/helpers'

class Test::Unit::TestCase
  include JsonExpressions::Test::Unit::Helpers
  WILDCARD_MATCHER = JsonExpressions::WILDCARD_MATCHER
end