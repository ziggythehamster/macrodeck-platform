require "rubygems"
require "validatable"
require "couchrest"
require "platform"

module MacroDeck
	# MacroDeck::Model is the base class for models provided by the platform.
	# Objects that are defined in the platform will inherit from DataObject.
	# This class inherits from CouchRest::ExtendedDocument.
	class Model < CouchRest::ExtendedDocument
		include Validatable
	end
end
