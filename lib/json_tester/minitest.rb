require 'json_tester'
require 'json_tester/minitest/unit/helpers'

class MiniTest::Unit::TestCase
	include JsonTester::MiniTest::Unit::Helpers
	WILDCARD_MATCHER = JsonTester::WILDCARD_MATCHER
end