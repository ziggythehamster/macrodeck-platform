require 'test/unit/testsuite'
require 'test/platform'
require 'test/data_object_definition'

module MacroDeck
	class TestSuite
		def self.suite
			suite  = Test::Unit::TestSuite.new("MacroDeck Platform Tests")
			suite << MacroDeck::Tests::Platform.suite
			suite << MacroDeck::Tests::DataObjectDefinition.suite

			return suite
		end
	end
end
