require 'minitest/unit'
require 'json_expressions'
require 'json_expressions/minitest/unit/helpers'

class MiniTest::Unit::TestCase
	include JsonExpressions::MiniTest::Unit::Helpers
	WILDCARD_MATCHER = JsonExpressions::WILDCARD_MATCHER
end