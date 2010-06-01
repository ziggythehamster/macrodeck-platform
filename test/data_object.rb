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
			def test_001_create_test_data_object_items
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
				object2 = object.dup
				object2["tags"] = ["test"]
				object2["created_by"] = "user/ZiggyTheHamster"
				object2["title"] = "Test Alternate Created By"
				object2["human_id"] = "alternate-created-by"
				object3 = object2.dup
				object3["title"] = "Test Alternate Updated By"
				object3["updated_by"] = "user/csakon"
				object3["human_id"] = "alternate-updated-by"

				test_object = ::DataObject.new(object)
				assert test_object.valid?
				assert test_object.save

				test_object2 = ::DataObject.new(object2)
				assert test_object2.valid?
				assert test_object2.save

				test_object3 = ::DataObject.new(object3)
				assert test_object3.valid?
				assert test_object3.save
			end
			
			# Tests that the previously created record can be retrieved.
			def test_002_get_test_data_object_items
				test_object = ::DataObject.view("by_title", :key => "Test Data Object Item", :include_docs => true)[0]
				assert test_object.valid?
				assert_equal [], test_object.path
				assert_equal "Test Data Object Item", test_object.title
				assert_equal ["awesome", "test", "bro"], test_object.tags
				assert_equal "user/System", test_object.created_by
				assert_equal "user/System", test_object.updated_by
				assert_equal "user/System", test_object.owned_by
				assert_equal "A fake test item to test with.", test_object.description
				assert_equal "test-data-object-item", test_object.human_id

				test_object2 = ::DataObject.view("by_created_by", :key => "user/ZiggyTheHamster", :include_docs => true)[0]
				assert test_object2.valid?
				assert_equal [], test_object2.path
				assert_equal "Test Alternate Created By", test_object2.title
				assert_equal ["test"], test_object2.tags
				assert_equal "user/ZiggyTheHamster", test_object2.created_by
				assert_equal "user/System", test_object2.updated_by
				assert_equal "user/System", test_object2.owned_by
				assert_equal "A fake test item to test with.", test_object2.description
				assert_equal "alternate-created-by", test_object2.human_id


				test_object3 = ::DataObject.view("by_updated_by", :key => "user/csakon", :include_docs => true)[0]
				assert test_object3.valid?
				assert_equal [], test_object3.path
				assert_equal "Test Alternate Updated By", test_object3.title
				assert_equal ["test"], test_object3.tags
				assert_equal "user/ZiggyTheHamster", test_object3.created_by
				assert_equal "user/csakon", test_object3.updated_by
				assert_equal "user/System", test_object3.owned_by
				assert_equal "A fake test item to test with.", test_object3.description
				assert_equal "alternate-updated-by", test_object3.human_id
			end

			
		end
	end
end
