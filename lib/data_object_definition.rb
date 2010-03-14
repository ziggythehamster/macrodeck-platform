# This class handles a data object definition record. When objects are defined,
# a class inheriting from DataObject is created.
class DataObjectDefinition < MacroDeck::Model
	# Mixins
	include CouchRest::Validation # FIXME: Use Validatable instead.

	# Properties
	property :object_type, String
	property :fields, Array
	property :validations, Array

	# Validations that happen on this class.
	validates_presence_of :object_type, :fields, :validations
	validates_with_method :fields, :validate_fields
	validates_with_method :validations, :validate_validations

	private
		# Returns true if the fields array is at least visibly valid.
		# We won't know for sure since we don't check every detail.
		def validate_fields
			if @fields.is_a?(Array)
				if @fields.length == 0
					return true
				elsif @fields.length > 0
					@fields.each do |field|
						if field.is_a?(Array) && field.length == 3 && field[0].is_a?(String) && field[1].is_a?(String) && (field[2].is_a?(TrueClass) || field[2].is_a?(FalseClass))
							return true
						else
							return [false, "has a field which is invalid"]
						end
					end
				end
			else
				return [false, "is not an array"]
			end
		end

		# Returns true if the validations array looks visibly valid.
		def validate_validations
			# TODO: STUB
		end
end
