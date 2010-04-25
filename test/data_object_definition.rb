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
			
			# Tests that the previously created object can be retrieved.
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
				assert_equal ::MacroDeckTestObject.properties[0].name, "not_required_str"
				assert_equal ::MacroDeckTestObject.properties[0].type, "String"
				assert_equal ::MacroDeckTestObject.properties[1].name, "required_str"
				assert_equal ::MacroDeckTestObject.properties[1].type, "String"
			end

			# Tests that the object's validations get populated.
			def test_005_defined_object_validations
				assert_equal ::MacroDeckTestObject.validations[0].class, 	Validatable::ValidatesTrueFor
				assert_equal ::MacroDeckTestObject.validations[0].attribute,	:not_required_str
				assert_equal ::MacroDeckTestObject.validations[1].class,	Validatable::ValidatesTrueFor
				assert_equal ::MacroDeckTestObject.validations[1].attribute,	:required_str
				assert_equal ::MacroDeckTestObject.validations[2].class,	Validatable::ValidatesPresenceOf
				assert_equal ::MacroDeckTestObject.validations[2].attribute,	:required_str
			end
		end
	end
end
