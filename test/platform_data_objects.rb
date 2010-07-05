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

			# Tests the common properties of all DataObjects.
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

			# Tests the common validations of all DataObjects
			def test_003_data_object_common_validations
				assert_equal Validatable::ValidatesPresenceOf,	::DataObject.validations[0].class
				assert_equal :path,				::DataObject.validations[0].attribute
				assert_equal Validatable::ValidatesPresenceOf,	::DataObject.validations[1].class
				assert_equal :tags,				::DataObject.validations[1].attribute
				assert_equal Validatable::ValidatesPresenceOf,	::DataObject.validations[2].class
				assert_equal :created_by,			::DataObject.validations[2].attribute
				assert_equal Validatable::ValidatesPresenceOf,	::DataObject.validations[3].class
				assert_equal :updated_by,			::DataObject.validations[3].attribute
				assert_equal Validatable::ValidatesPresenceOf,	::DataObject.validations[4].class
				assert_equal :owned_by,				::DataObject.validations[4].attribute
				assert_equal Validatable::ValidatesTrueFor,	::DataObject.validations[5].class
				assert_equal :path,				::DataObject.validations[5].attribute
				assert_equal Validatable::ValidatesTrueFor,	::DataObject.validations[6].class
				assert_equal :tags,				::DataObject.validations[6].attribute
				assert_equal Validatable::ValidatesTrueFor,	::DataObject.validations[7].class
				assert_equal :created_by,			::DataObject.validations[7].attribute
				assert_equal Validatable::ValidatesTrueFor,	::DataObject.validations[8].class
				assert_equal :updated_by,			::DataObject.validations[8].attribute
				assert_equal Validatable::ValidatesTrueFor,	::DataObject.validations[9].class
				assert_equal :owned_by,				::DataObject.validations[9].attribute
			end

			# Test the behavior of Country.
			def test_004_country
				assert_equal ::DataObject,			::Country.superclass
			end

			# Test the properties of Country.
			def test_005_country_properties
				assert_equal "abbreviation",	::Country.properties[8].name
				assert_equal "String",		::Country.properties[8].type
			end

			# Test the validations of Country.
			def test_006_country_validations
				assert_equal Validatable::ValidatesTrueFor,	::Country.validations[10].class
				assert_equal :abbreviation,			::Country.validations[10].attribute
				assert_equal Validatable::ValidatesPresenceOf,	::Country.validations[11].class
				assert_equal :abbreviation,			::Country.validations[11].attribute
				assert_equal Validatable::ValidatesLengthOf,	::Country.validations[12].class
				assert_equal :abbreviation,			::Country.validations[12].attribute
				assert_equal 2,					::Country.validations[12].is
			end

			# Test the behavior of Region.
			def test_007_region
				assert_equal ::DataObject,			::Region.superclass
			end

			# Test the properties of Region.
			def test_008_region_properties
				assert_equal "abbreviation",			::Region.properties[8].name
				assert_equal "String",				::Region.properties[8].type
			end

			# Test the validations of Region
			def test_009_region_validations
				assert_equal Validatable::ValidatesTrueFor,	::Region.validations[10].class
				assert_equal :abbreviation,			::Region.validations[10].attribute
			end

			# Test the behavior of Locality.
			def test_010_locality
				assert_equal ::DataObject,			::Locality.superclass
			end

			# Test the validations of Locality (there are no properties).
			def test_012_locality_validations
				assert_equal Validatable::ValidatesPresenceOf,	::Locality.validations[10].class
				assert_equal :title,				::Locality.validations[10].attribute
			end

			# Test the behavior of Place.
			def test_013_place
				assert_equal ::DataObject,			::Place.superclass
			end

			# Test the properties of Place.
			def test_014_place_properties
				assert_equal "address",				::Place.properties[8].name
				assert_equal "String",				::Place.properties[8].type
				assert_equal "postal_code",			::Place.properties[9].name
				assert_equal "String",				::Place.properties[9].type
				assert_equal "phone_number",			::Place.properties[10].name
				assert_equal "String",				::Place.properties[10].type
				assert_equal "url",				::Place.properties[11].name
				assert_equal "String",				::Place.properties[11].type
				assert_equal "geo",				::Place.properties[12].name
				assert_equal "Array",				::Place.properties[12].type
				assert_equal "cuisine",				::Place.properties[13].name
				assert_equal "String",				::Place.properties[13].type
				assert_equal "features",			::Place.properties[14].name
				assert_equal "Array",				::Place.properties[14].type
				assert_equal "parking",				::Place.properties[15].name
				assert_equal "String",				::Place.properties[15].type
				assert_equal "hours",				::Place.properties[16].name
				assert_equal "Hash",				::Place.properties[16].type
			end
		end
	end
end
