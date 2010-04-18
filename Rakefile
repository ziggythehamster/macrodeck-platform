require "init"
require "test/unit/testsuite"
require "test/unit/ui/console/testrunner"
require "test/platform"
require "test/test_suite"

namespace :macrodeck do
	desc "Do a fresh test"
	task(:test => [:clear_test, :run_test])

	desc "Clear the test database"
	task(:clear_test) do
		db = CouchRest.database("macrodeck-test")
		db.delete!
	end

	desc "Run the MacroDeck test suite"
	task(:run_test) do
		Test::Unit::UI::Console::TestRunner.run(MacroDeck::TestSuite)
	end
end
