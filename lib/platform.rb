require "rubygems"
require "validatable"
require "couchrest"
require "data_object_definition"

module MacroDeck
	# This class starts up the platform, pulls data object definitions, etc.
	#
	# Usage:
	# 
	#     MacroDeck::Platform.start!(database_name)
	#
	# Calling it more than once will not start the platform more than once.
	class Platform
		class << self
			attr_reader :database_name
			attr_reader :started

			# Starts the platform, connects to CouchDB, etc.
			def start!(database_name)
				unless @started
					@database_name = database_name
					@started = true

					# Define the base inherited model like this so that we can specify the
					# database_name at runtime. 
					Kernel.eval "
					module MacroDeck
						class Model < CouchRest::ExtendedDocument
							include Validatable
							use_database CouchRest.database!(\"#{@database_name}\")
						end
					end"

					# Now create the DataObjectDefinition class, which bootstraps everything
					# else.
					Kernel.eval "class ::DataObjectDefinition < MacroDeck::Model; end"
					
					# Include the class methods.
					::DataObjectDefinition.send(:include, ::MacroDeck::PlatformSupport::DataObjectDefinition)
				end
			end
		end
	end
end
