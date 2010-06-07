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
				object2["path"] = ["level1"]
				object2["tags"] = ["test"]
				object2["created_by"] = "user/testCreatedBy"
				object2["updated_by"] = "user/testCreatedBy"
				object2["owned_by"] = "user/testCreatedBy"
				object2["title"] = "Test Alternate Created By"
				object2["human_id"] = "alternate-created-by"
				object3 = object2.dup
				object3["path"] = ["level1", "level2"]
				object3["title"] = "Test Alternate Updated By"
				object3["created_by"] = "user/testUpdatedBy"
				object3["updated_by"] = "user/testUpdatedBy"
				object3["owned_by"] = "user/testUpdatedBy"
				object3["human_id"] = "alternate-updated-by"
				object4 = object3.dup
				object4["path"] = ["level1", "level2", "level3"]
				object4["title"] = "Test Alternate Owned By"
				object4["created_by"] = "user/testOwnedBy"
				object4["updated_by"] = "user/testOwnedBy"
				object4["owned_by"] = "user/testOwnedBy"
				object4["human_id"] = "alternate-owned-by"

				test_object = ::DataObject.new(object)
				assert test_object.valid?
				assert test_object.save

				test_object2 = ::DataObject.new(object2)
				assert test_object2.valid?
				assert test_object2.save

				test_object3 = ::DataObject.new(object3)
				assert test_object3.valid?
				assert test_object3.save

				test_object4 = ::DataObject.new(object4)
				assert test_object4.valid?
				assert test_object4.save
			end
			
			# Tests find by title.
			def test_002_find_by_title
				# Test find by title.
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
			end

			# Test find by created by
			def test_003_find_by_created_by
				test_object2 = ::DataObject.view("by_created_by", :key => "user/testCreatedBy", :include_docs => true)[0]
				assert test_object2.valid?
				assert_equal ["level1"], test_object2.path
				assert_equal "Test Alternate Created By", test_object2.title
				assert_equal ["test"], test_object2.tags
				assert_equal "user/testCreatedBy", test_object2.created_by
				assert_equal "user/testCreatedBy", test_object2.updated_by
				assert_equal "user/testCreatedBy", test_object2.owned_by
				assert_equal "A fake test item to test with.", test_object2.description
				assert_equal "alternate-created-by", test_object2.human_id
			end

			# Test find by updated by
			def test_004_find_by_updated_by
				test_object3 = ::DataObject.view("by_updated_by", :key => "user/testUpdatedBy", :include_docs => true)[0]
				assert test_object3.valid?
				assert_equal ["level1", "level2"], test_object3.path
				assert_equal "Test Alternate Updated By", test_object3.title
				assert_equal ["test"], test_object3.tags
				assert_equal "user/testUpdatedBy", test_object3.created_by
				assert_equal "user/testUpdatedBy", test_object3.updated_by
				assert_equal "user/testUpdatedBy", test_object3.owned_by
				assert_equal "A fake test item to test with.", test_object3.description
				assert_equal "alternate-updated-by", test_object3.human_id
			end

			# Test find by owned by.
			def test_005_find_by_owned_by
				test_object4 = ::DataObject.view("by_owned_by", :key => "user/testOwnedBy", :include_docs => true)[0]
				assert test_object4.valid?
				assert_equal ["level1", "level2", "level3"], test_object4.path
				assert_equal "Test Alternate Owned By", test_object4.title
				assert_equal ["test"], test_object4.tags
				assert_equal "user/testOwnedBy", test_object4.created_by
				assert_equal "user/testOwnedBy", test_object4.updated_by
				assert_equal "user/testOwnedBy", test_object4.owned_by
				assert_equal "A fake test item to test with.", test_object4.description
				assert_equal "alternate-owned-by", test_object4.human_id
			end

			# Test find by human ID
			def test_006_find_by_human_id
				test_object5 = ::DataObject.view("by_human_id", :key => "alternate-owned-by", :include_docs => true)[0]
				assert test_object5.valid?
				assert_equal ["level1", "level2", "level3"], test_object5.path
				assert_equal "Test Alternate Owned By", test_object5.title
				assert_equal ["test"], test_object5.tags
				assert_equal "user/testOwnedBy", test_object5.created_by
				assert_equal "user/testOwnedBy", test_object5.updated_by
				assert_equal "user/testOwnedBy", test_object5.owned_by
				assert_equal "A fake test item to test with.", test_object5.description
				assert_equal "alternate-owned-by", test_object5.human_id
			end

			# Test that tag reduce view is working.
			def test_007_tag_count
				test_tags1 = ::DataObject.view("by_tags", :key => "awesome")
				test_tags2 = ::DataObject.view("by_tags", :key => "test")
				test_tags3 = ::DataObject.view("by_tags", :key => "bro")
				assert 1, test_tags1.length
				assert 4, test_tags2.length
				assert 1, test_tags3.length
			end
		end
	end
end
