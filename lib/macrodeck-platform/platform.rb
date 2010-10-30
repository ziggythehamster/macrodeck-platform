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

			# Processes include directives in the index, map, or reduce function.
			#
			# The format is as follows:
			#
			#   /*! include file.js */
			#
			# The file should exist in jslib/.
			# The spaces should be left as is.
			def process_includes(string)
				regex = /\/\*! include (.*) \*\//
				new_string = string

				# Check to see if the string matches. If so, fetch the file and include it.
				if !new_string.nil? && new_string.match(regex)
					files_to_read = new_string.match(regex).captures
					files_to_read.each do |f|
						filedata = File.open(File.expand_path(File.dirname(__FILE__) + "/jslib/#{f}")).read
						new_string.gsub!(/\/\*! include #{f} \*\//, filedata)
					end
				end

				return new_string
			end
		end
	end
end
