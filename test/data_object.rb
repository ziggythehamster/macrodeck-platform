require "test/unit"

# Does a test against DataObject
module MacroDeck
	module Tests
		class DataObject < Test::Unit::TestCase
                        # Starts the platform with known values.
			def setup
				MacroDeck::Platform.start!("macrodeck-test")
			end

			# Tests that stuff exists that should exist.
			def test_000_sanity_check
				assert_nothing_raised do
					::DataObject
					::MacroDeck
					::MacroDeck::Model
				end
			end

			# Creates a test item and saves it to the database.
			def test_001_create_test_data_object_item
				object = {
					"path" => [],
					"tags" => ["awesome", "test", "bro"],
					"created_by" => "user/System",
					"updated_by" => "user/System",
					"owned_by" => "user/System",
					"title" => "Test Data Object Item",
					"description" => "A fake test item to test with.",
					"human_id" => "test-data-object-item"
				}
				test_object = ::DataObject.new(object)
				assert test_object.valid?
				assert test_object.save
			end
			
			# Tests that the previously created record can be retrieved.
			def test_002_get_test_data_object_item
				test_object = ::DataObject.view("by_title", :key => "Test Data Object Item", :include_docs => true)[0]
				assert test_object.valid?
				assert_equal [], test_object.path
				assert_equal ["awesome", "test", "bro"], test_object.tags
				assert_equal "user/System", test_object.created_by
				assert_equal "user/System", test_object.updated_by
				assert_equal "user/System", test_object.owned_by
				assert_equal "A fake test item to test with.", test_object.description
				assert_equal "test-data-object-item", test_object.human_id
			end
		end
	end
end
