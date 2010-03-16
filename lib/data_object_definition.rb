# This class handles a data object definition record. When objects are defined,
# a class inheriting from DataObject is created.
class DataObjectDefinition < MacroDeck::Model
	# Properties
	property :object_type,	String
	property :fields,	Array
	property :validations,	Array

	# Validations that happen on this class.
	validates_presence_of :object_type
	validates_presence_of :fields
	validates_presence_of :validations
	validates_true_for :fields, :logic => :validate_fields, :message => "is not valid"
	validates_true_for :validations, :logic => :validate_validations, :message => "is not valid"

	private
		# Returns true if the fields array is at least visibly valid.
		# We won't know for sure since we don't check every detail.
		def validate_fields
			if self.fields.is_a?(Array)
				if self.fields.length == 0
					return true
				else
					self.fields.each do |field|
						if field.is_a?(Array) && field.length == 3 && field[0].is_a?(String) && field[1].is_a?(String) && (field[2].is_a?(TrueClass) || field[2].is_a?(FalseClass))
							return true
						else
							return false
						end
					end
				end
			else
				return false
			end
		end

		# Returns true if the validations array looks visibly valid.
		def validate_validations
			if self.validations.is_a?(Array)
				if self.validations.length == 0
					return true
				else
					self.validations.each do |validation|
						if validation.is_a?(Array) && validation.length == 2 && validation[0].is_a?(String)
							return true
						else
							return false
						end
					end
				end
			else
				return false
			end
		end
end
