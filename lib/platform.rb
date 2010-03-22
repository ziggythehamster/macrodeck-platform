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

					# Add the use_database to the model
					Kernel.eval "module MacroDeck
						class Model < CouchRest::ExtendedDocument
							use_database CouchRest.new.database!(\"#{@database_name}\")
						end
					end"

					# And since DataObjectDefinition is already defined...
					Kernel.eval "class DataObjectDefinition < MacroDeck::Model
						use_database CouchRest.new.database!(\"#{@database_name}\")
					end"
				end
			end
		end
	end
end
