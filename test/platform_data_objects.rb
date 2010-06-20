require "test/unit"

# Does a test against the platform data objects.
module MacroDeck
	module Tests
		class PlatformDataObjects < Test::Unit::TestCase
			def test_000_setup
				assert_nothing_raised do
					::MacroDeck::Platform.start!("macrodeck-test")
					::MacroDeck::PlatformDataObjects.define!
				end
			end

			# Tests that stuff exists that should exist.
			def test_001_sanity_check
				assert_nothing_raised do
					::Country
					::Region
					::Locality
					::Place
				end
			end

			# Tests that country has the appropriate properties.
			def test_002_defined_object_properties
				puts ::Country.properties.inspect
				#assert_equal "not_required_str",	::MacroDeckTestObject.properties[0].name
				#assert_equal "String",			::MacroDeckTestObject.properties[0].type
				#assert_equal "required_str",		::MacroDeckTestObject.properties[1].name
				#assert_equal "String",			::MacroDeckTestObject.properties[1].type
				#assert_equal "validated_str",		::MacroDeckTestObject.properties[2].name
				#assert_equal "String",			::MacroDeckTestObject.properties[2].type
			end
		end
	end
end
