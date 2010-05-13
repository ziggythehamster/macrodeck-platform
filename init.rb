# Load required files and libraries
$LOAD_PATH << "./lib"

require "rubygems"

begin
	gem "jnunemaker-validatable"
rescue Gem::LoadError
	puts "*** MISSING DEPENDENCY ***\n"
	puts "Please run gem install jnunemaker-validatable --source http://gemcutter.org\n"
	puts "(now exiting)"
	exit 1
end

require "validatable"
require "couchrest"
require "model"
require "data_object_definition"
require "data_object"
require "platform"
