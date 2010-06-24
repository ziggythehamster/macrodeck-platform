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
					::DataObject
				end
			end

			def test_002_data_object_common_properties
				assert_equal "path",		::DataObject.properties[0].name
				assert_equal ["String"],	::DataObject.properties[0].type
				assert_equal "tags",		::DataObject.properties[1].name
				assert_equal ["String"],	::DataObject.properties[1].type
				assert_equal "created_by",	::DataObject.properties[2].name
				assert_equal "String",		::DataObject.properties[2].type
				assert_equal "updated_by",	::DataObject.properties[3].name
				assert_equal "String",		::DataObject.properties[3].type
				assert_equal "owned_by",	::DataObject.properties[4].name
				assert_equal "String",		::DataObject.properties[4].type
				assert_equal "title",		::DataObject.properties[5].name
				assert_equal "String",		::DataObject.properties[5].type
				assert_equal "description",	::DataObject.properties[6].name
				assert_equal "String",		::DataObject.properties[6].type
				assert_equal "human_id",	::DataObject.properties[7].name
				assert_equal "String",		::DataObject.properties[7].type
			end

			def test_002_country_properties
				assert_equal "abbreviation",	::Country.properties[8].name
				assert_equal "String",		::Country.properties[8].type
			end
		end
	end
end
