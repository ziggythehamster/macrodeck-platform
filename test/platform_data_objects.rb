require "test/unit"

CUSTOM_PROP_INDEX = 9 # The number to add to the index of properties to get to the custom ones defined on the object type.

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
				assert_equal "created_at",	::DataObject.properties[8].name
				assert_equal "String",		::DataObject.properties[8].type
				assert_equal "updated_at",	::DataObject.properties[9].name
				assert_equal "String",		::DataObject.properties[9].type
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
				assert_equal Validatable::ValidatesLengthOf,	::DataObject.validations[5].class
				assert_equal :path,				::DataObject.validations[5].attribute
				assert_equal 1,					::DataObject.validations[5].minimum
			end

			# Test the behavior of Country.
			def test_004_country
				assert_equal ::DataObject,			::Country.superclass
				country = ::Country.new
				country.title = "Test"; assert !country.valid?
				country.abbreviation = "TE"; assert !country.valid?
				country.tags = ["test", "tags"]; assert !country.valid?
				country.created_by = "_system"; assert !country.valid?
				country.updated_by = "_system"; assert !country.valid?
				country.owned_by = "_system"; assert !country.valid?
				country.path = ["country-test"]; assert country.valid?
			end

			# Test the properties of Country.
			def test_005_country_properties
				assert_equal "abbreviation",	::Country.properties[8].name
				assert_equal "String",		::Country.properties[8].type
			end

			# Test the validations of Country.
			def test_006_country_validations
				assert_equal Validatable::ValidatesPresenceOf,	::Country.validations[6].class
				assert_equal :abbreviation,			::Country.validations[6].attribute
				assert_equal Validatable::ValidatesLengthOf,	::Country.validations[7].class
				assert_equal :abbreviation,			::Country.validations[7].attribute
				assert_equal 2,					::Country.validations[7].is
			end

			# Test the behavior of Region.
			def test_007_region
				assert_equal ::DataObject,			::Region.superclass
				region = ::Region.new
				region.title = "Test"; assert !region.valid?
				region.abbreviation = "TE"; assert !region.valid?
				region.tags = ["test", "tags"]; assert !region.valid?
				region.created_by = "_system"; assert !region.valid?
				region.updated_by = "_system"; assert !region.valid?
				region.owned_by = "_system"; assert !region.valid?
				region.path = ["region-test"]; assert region.valid?
			end

			# Test the properties of Region.
			def test_008_region_properties
				assert_equal "abbreviation",			::Region.properties[8].name
				assert_equal "String",				::Region.properties[8].type
			end

			# Test the validations of Region
			def test_009_region_validations
				# None.
			end

			# Test the behavior of Locality.
			def test_010_locality
				assert_equal ::DataObject,			::Locality.superclass
				locality = ::Locality.new
				locality.title = "Test"; assert !locality.valid?
				locality.tags = [ "test", "tags"]; assert !locality.valid?
				locality.created_by = "_system"; assert !locality.valid?
				locality.updated_by = "_system"; assert !locality.valid?
				locality.owned_by = "_system"; assert !locality.valid?
				locality.path = ["locality-test"]; assert locality.valid?
			end

			# Test the validations of Locality (there are no properties).
			def test_012_locality_validations
				assert_equal Validatable::ValidatesPresenceOf,	::Locality.validations[6].class
				assert_equal :title,				::Locality.validations[6].attribute
			end

			# Test the behavior of Place.
			def test_013_place
				assert_equal ::DataObject,			::Place.superclass
				place = ::Place.new
				place.title = "Place"; assert !place.valid?
				place.tags = ["complicated", "test"]; assert !place.valid?
				place.created_by = "_system"; assert !place.valid?
				place.updated_by = "_system"; assert !place.valid?
				place.owned_by = "_system"; assert !place.valid?
				place.path = ["place-test"]; assert place.valid?
				place.credit_cards_accepted = ["test"]; assert !place.valid?
				place.credit_cards_accepted = ["Visa"]; assert place.valid?
				place.features = ["test"]; assert !place.valid?
				place.features = ["Wi-Fi"]; assert place.valid?
				place.fare = ["test"]; assert !place.valid?
				place.fare = ["American"]; assert place.valid?
				place.alcohol = ["test"]; assert !place.valid?
				place.alcohol = ["Beer"]; assert place.valid?
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
				assert_equal ["Float"],				::Place.properties[12].type
				assert_equal "fare",				::Place.properties[13].name
				assert_equal ["String"],			::Place.properties[13].type
				assert_equal "features",			::Place.properties[14].name
				assert_equal ["String"],			::Place.properties[14].type
				assert_equal "parking",				::Place.properties[15].name
				assert_equal "String",				::Place.properties[15].type
				assert_equal "hours",				::Place.properties[16].name
				assert_equal "Hash",				::Place.properties[16].type
				assert_equal "atmosphere",			::Place.properties[17].name
				assert_equal "String",				::Place.properties[17].type
				assert_equal "alcohol",				::Place.properties[18].name
				assert_equal ["String"],			::Place.properties[18].type
				assert_equal "credit_cards_accepted",		::Place.properties[19].name
				assert_equal ["String"],			::Place.properties[19].type
				assert_equal "reservations",			::Place.properties[20].name
				assert_equal "String",				::Place.properties[20].type
			end

			# Test the validations of Place.
			def test_015_place_validations
				assert_equal Validatable::ValidatesListItemsInList,	::Place.validations[6].class
				assert_equal :features,					::Place.validations[6].attribute
				assert_equal Validatable::ValidatesListItemsInList,	::Place.validations[7].class
				assert_equal :alcohol,					::Place.validations[7].attribute
				assert_equal Validatable::ValidatesListItemsInList,	::Place.validations[8].class
				assert_equal :fare,					::Place.validations[8].attribute
				assert_equal Validatable::ValidatesListItemsInList,	::Place.validations[9].class
				assert_equal :credit_cards_accepted,			::Place.validations[9].attribute
			end

			# Test the behavior of Neighborhood
			def test_016_neighborhood
				assert_equal ::DataObject,			::Neighborhood.superclass
			end

			# Test the validations of Neighborhood (there are no properties).
			def test_017_neighborhood_validations
				assert_equal Validatable::ValidatesPresenceOf,	::Neighborhood.validations[6].class
				assert_equal :title,				::Neighborhood.validations[6].attribute
			end

			# Test the behavior of Event.
			def test_018_event
				assert_equal ::DataObject,			::Event.superclass
			end

			# Tests the properties of Event.
			def test_019_event_properties
				assert_equal "start_time",			::Event.properties[8].name
				assert_equal "Time",				::Event.properties[8].type
				assert_equal "end_time",			::Event.properties[9].name
				assert_equal "Time",				::Event.properties[9].type
				assert_equal "recurrence",			::Event.properties[10].name
				assert_equal "String",				::Event.properties[10].type
				assert_equal "event_type",			::Event.properties[11].name
				assert_equal "String",				::Event.properties[11].type
			end

			# Tests the validations of Event.
			def test_020_event_validations
				assert_equal Validatable::ValidatesPresenceOf,	::Event.validations[6].class
				assert_equal :start_time,			::Event.validations[6].attribute
				assert_equal Validatable::ValidatesPresenceOf,	::Event.validations[7].class
				assert_equal :title,				::Event.validations[7].attribute
				assert_equal Validatable::ValidatesListItemsInList,	::Event.validations[8].class
				assert_equal :event_type,				::Event.validations[8].attribute
				assert_equal Validatable::ValidatesListItemsInList,	::Event.validations[9].class
				assert_equal :recurrence,				::Event.validations[9].attribute
			end
		end
	end
end
