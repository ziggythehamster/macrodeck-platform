namespace :macrodeck do
	desc "Do a fresh test"
	task(:test => [:clear_test, :run_test])

	desc "Clear the test database"
	task(:clear_test => :environment) do
		begin
			db = CouchRest.database("macrodeck-test")
			db.delete!
		rescue
			puts "Couldn't clear the database, this might be an error..."
		end
	end

	desc "Run the MacroDeck test suite"
	task(:run_test => :environment) do
		require "test/unit/testsuite"
		require "test/unit/ui/console/testrunner"
		require "test/platform"
		require "test/test_suite"

		Test::Unit::UI::Console::TestRunner.run(MacroDeck::TestSuite)
	end

	desc "Load the predefined data objects"
	task(:load_shipped_objects => :environment) do
		db = ENV['DB'] || "macrodeck-development"
		puts "Loading shipped objects into #{db}"
		::MacroDeck::Platform.start!(db)
		::MacroDeck::PlatformDataObjects.define!
	end
end
