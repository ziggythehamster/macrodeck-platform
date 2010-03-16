require "model"
require "data_object_definition"

# This class starts up the platform, pulls data object definitions, etc.
#
# Usage:
# 
#     MacroDeck::Platform.start!(database_name)
#
# Calling it more than once will not start the platform more than once.
class MacroDeck::Platform
	class << self
		attr_reader :database_name

		def start!(database_name)
			@database_name = database_name
		end
	end
end
