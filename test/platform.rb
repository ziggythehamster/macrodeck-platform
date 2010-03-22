require "test/unit"

# Does a test against MacroDeck::Platform
module MacroDeck
	module Tests
		class Platform < Test::Unit::TestCase
			# Starts the platform with known values.
			def setup
				MacroDeck::Platform.start!("macrodeck-test")
			end

			# Tests the database_name is set by MacroDeck::Platform
			def test_database_name
				assert_equal MacroDeck::Platform.database_name, "macrodeck-test"
			end

			# Tests that the started flag is set.
			def test_started
				assert MacroDeck::Platform.started
			end
		end
	end
end
