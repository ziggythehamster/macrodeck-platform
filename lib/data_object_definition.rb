# This class handles a data object definition record. When objects are defined,
# a class inheriting from DataObject is created.
class DataObjectDefinition < MacroDeck::Model
	# Properties
	property :object_type
	property :fields
	property :validations

	# Attributes
	attr_reader :defined # Is this object defined already?

	# Validations that happen on this class.
	validates_presence_of :object_type
	validates_presence_of :fields
	validates_presence_of :validations
	validates_true_for :object_type, :logic => lambda { object_type.is_a?(String) }
	validates_true_for :fields, :logic => :validate_fields, :message => "is not valid"
	validates_true_for :validations, :logic => :validate_validations, :message => "is not valid"

	# Executes the code necessary to define this object
	def define!
		properties = ""
		class_body = ""

		# Populate properties.
		if self.valid?
			# Iterate all of the fields and define them.
			self.fields.each do |field|
				symbol = field[0].to_sym.inspect
				klass = eval(field[1].split(" ")[0]) # NB: This could potentially be a very unsafe operation...
				properties << "property #{symbol}\n"
				properties << "validates_true_for #{symbol}, :logic => lambda { #{field[0]}.is_a?(#{klass}) }\n"
				properties << "validates_presence_of #{symbol}\n" if field[2] == true
			end

			# TODO: Iterate the validations and define them.

			# Define the class.
			klass = self.object_type.split(" ")[0]
			class_body =
				"class #{klass} < MacroDeck::Model
					#{properties}
				end"
			puts class_body
		end
	end

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
