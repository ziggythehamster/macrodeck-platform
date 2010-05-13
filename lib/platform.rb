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
					module ::MacroDeck
						class Model < CouchRest::ExtendedDocument
							include Validatable
							use_database CouchRest.database!(\"#{@database_name}\")
						end
					end"

					# Now create the DataObjectDefinition class, which bootstraps everything
					# else.
					Kernel.eval "class ::DataObjectDefinition < ::MacroDeck::Model; end"
					
					# Now create the DataObject class, which is the parent of all classes
					# defined by DataObject.
					Kernel.eval "class ::DataObject < ::MacroDeck::Model; end"

					# Include the class methods.
					::DataObjectDefinition.send(:include, ::MacroDeck::PlatformSupport::DataObjectDefinition)
					::DataObject.send(:include, ::MacroDeck::PlatformSupport::DataObject)
				end
			end
		end
	end
end
