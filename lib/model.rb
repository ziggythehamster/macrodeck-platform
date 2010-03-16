require "validatable"

# MacroDeck::Model is the base class for models provided by the platform.
# Objects that are defined in the platform will inherit from DataObject.
# This class inherits from CouchRest::ExtendedDocument.
class MacroDeck::Model < CouchRest::ExtendedDocument
	include Validatable

	use_database CouchRest.new.database!(MacroDeck::Platform.database_name)
end
