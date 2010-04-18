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
						["required_str", "String", true]
					],
					"validations" => []
				}
				test_object = ::DataObjectDefinition.new(object)
				assert test_object.valid?
				assert test_object.save
			end
			
			# Tests that the previously created object can be retrieved.
			def test_002_get_test_definition
				test_object = ::DataObjectDefinition.view("by_object_type", :key => "MacroDeckTestObject")[0]
				assert test_object.valid?
				assert_equal test_object.fields, [
					["not_required_str", "String", false],
					["required_str", "String", true]
				]
				assert_equal test_object.validations, []
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
				puts ::MacroDeckTestObject.class
			end
		end
	end
end
