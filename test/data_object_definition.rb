require "test/unit"

# Does a test against DataObjectDefinition
module MacroDeck
	module Tests
		class DataObjectDefinition < Test::Unit::TestCase
                        # Starts the platform with known values.
			def setup
				MacroDeck::Platform.start!("macrodeck-test")
			end

			# Tests that stuff exists that should exist.
			def test_000_sanity_check
				assert_nothing_raised do
					::DataObjectDefinition
					::MacroDeck
					::MacroDeck::Model
				end
			end

			# Creates a test object and verifies it exists.
			def test_001_create_test_definition
				object = {
					"object_type" => "MacroDeckTestObject",
					"fields" => [
						["not_required_str", "String", false],
						["required_str", "String", true],
						["validated_str", "String", false]
					],
					"validations" => [
						[ "validates_inclusion_of", "validated_str", { "within" => [ "One", "Two", "Three" ], "allow_nil" => true } ]
					]
				}
				test_object = ::DataObjectDefinition.new(object)
				assert test_object.valid?
				assert test_object.save
			end
			
			# Tests that the previously created object can be retrieved and has the correct fields.
			def test_002_get_test_definition
				test_object = ::DataObjectDefinition.view("by_object_type", :key => "MacroDeckTestObject")[0]
				assert test_object.valid?
				assert_equal [
					["not_required_str", "String", false],
					["required_str", "String", true],
					["validated_str", "String", false]
				], test_object.fields
				assert_equal [
					[ "validates_inclusion_of", "validated_str", { "within" => [ "One", "Two", "Three" ], "allow_nil" => true } ]
				], test_object.validations
				assert_equal "MacroDeckTestObject", test_object["_id"]
			end

			# Tests that the define! method works.
			def test_003_get_defined_object
				test_definition = ::DataObjectDefinition.view("by_object_type", :key => "MacroDeckTestObject")[0]
				assert test_definition.valid?

				# Make sure that the object isn't yet defined
				assert_raise NameError do
					::MacroDeckTestObject
				end
				test_definition.define!
				assert_nothing_raised do
					::MacroDeckTestObject
				end
			end

			# Tests that the object's properties gets populated.
			def test_004_defined_object_properties
				assert_equal "not_required_str",	::MacroDeckTestObject.properties[0].name
				assert_equal "String",			::MacroDeckTestObject.properties[0].type
				assert_equal "required_str",		::MacroDeckTestObject.properties[1].name
				assert_equal "String",			::MacroDeckTestObject.properties[1].type
				assert_equal "validated_str",		::MacroDeckTestObject.properties[2].name
				assert_equal "String",			::MacroDeckTestObject.properties[2].type
			end

			# Tests that the object's validations get populated.
			def test_005_defined_object_validations
				assert_equal Validatable::ValidatesTrueFor,		::MacroDeckTestObject.validations[0].class
				assert_equal :not_required_str,				::MacroDeckTestObject.validations[0].attribute
				assert_equal Validatable::ValidatesTrueFor,		::MacroDeckTestObject.validations[1].class
				assert_equal :required_str,				::MacroDeckTestObject.validations[1].attribute
				assert_equal Validatable::ValidatesPresenceOf,		::MacroDeckTestObject.validations[2].class
				assert_equal :required_str,				::MacroDeckTestObject.validations[2].attribute
				assert_equal Validatable::ValidatesTrueFor,		::MacroDeckTestObject.validations[3].class
				assert_equal :validated_str,				::MacroDeckTestObject.validations[3].attribute
				assert_equal Validatable::ValidatesInclusionOf,		::MacroDeckTestObject.validations[4].class
				assert_equal :validated_str,				::MacroDeckTestObject.validations[4].attribute
				assert_equal ["One", "Two", "Three"],			::MacroDeckTestObject.validations[4].within
			end
		end
	end
end
