require 'test/unit/testsuite'
require 'test/platform'

module MacroDeck
	class TestSuite
		def self.suite
			suite  = Test::Unit::TestSuite.new
			suite << MacroDeck::Tests::Platform.suite

			return suite
		end
	end
end
