require "init"
require "test/unit/testsuite"
require "test/unit/ui/console/testrunner"
require "test/platform"
require "test/test_suite"

namespace :macrodeck do
	desc "Run the MacroDeck test suite"
	task(:test) do
		Test::Unit::UI::Console::TestRunner.run(MacroDeck::TestSuite)
	end
end
