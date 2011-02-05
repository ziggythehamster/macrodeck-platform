# Load required files and libraries
$LOAD_PATH << File.join(File.dirname(__FILE__), "lib")

require "rubygems"
require "validatable"
require "couchrest"
require "couchrest_extended_document"
require "macrodeck-platform"
