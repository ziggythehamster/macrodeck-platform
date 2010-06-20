require 'test/unit/testsuite'
require 'test/platform'
require 'test/data_object_definition'
require 'test/data_object'
require 'test/platform_data_objects'

module MacroDeck
	class TestSuite
		def self.suite
			suite  = Test::Unit::TestSuite.new("MacroDeck Platform Tests")
			suite << MacroDeck::Tests::Platform.suite
			suite << MacroDeck::Tests::DataObjectDefinition.suite
			suite << MacroDeck::Tests::DataObject.suite
			suite << MacroDeck::Tests::PlatformDataObjects.suite

			return suite
		end
	end
end
