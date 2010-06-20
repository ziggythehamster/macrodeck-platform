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
				assert_equal "abbreviation",	::Country.properties[0].name
				assert_equal "String",		::Country.properties[0].type
			end
		end
	end
end
