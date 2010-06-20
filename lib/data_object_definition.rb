# This class handles a data object definition record. When objects are defined,
# a class inheriting from DataObject is created. The actual class is created in
# platform.rb because we can't specify the database name at runtime in another
# way.
module MacroDeck
	module PlatformSupport
		module DataObjectDefinition
			def self.included(base)
				base.unique_id :object_type
				base.property :object_type
				base.property :fields
				base.property :validations

				base.view_by :object_type

				base.send(:attr_reader, :defined)
                                
				# Validations that happen on this class.
				base.validates_presence_of :object_type
				base.validates_presence_of :fields
				base.validates_presence_of :validations
				base.validates_true_for :object_type, :logic => lambda { object_type.is_a?(String) }
				base.validates_true_for :fields, :logic => :validate_fields, :message => "is not valid"
				base.validates_true_for :validations, :logic => :validate_validations, :message => "is not valid"
			end

			# Executes the code necessary to define this object
			def define!
				properties = ""
				validations = ""
				class_body = ""

				@defined = false if @defined.nil?

				unless @defined
					@defined = true

					# Populate properties.
					if self.valid?
						# Iterate all of the fields and define them.
						self.fields.each do |field|
							symbol = field[0].to_sym.inspect
							klass = eval(field[1].split(" ")[0]) # NB: This could potentially be a very unsafe operation...
							properties << "property #{symbol}\n"
							properties << "validates_true_for #{symbol}, :logic => lambda { #{field[0]}.is_a?(::#{klass}) }\n"
							properties << "validates_presence_of #{symbol}\n" if field[2] == true
						end

						# Iterate the validations and define them.
						self.validations.each do |validation|
							symbol = validation[1].to_sym.inspect
	
							if validation.length == 3
								# Build the validation if arguments are required
								args = {}
								validation[2].each_pair do |key, value|
									args[key.to_sym] = value
								end
								validations << "#{validation[0].to_s} #{symbol}, #{args.inspect}\n"
							elsif validation.length == 2
								# Build the validation if arguments aren't required.
								validations << "#{validation[0].to_s} #{symbol}\n"
							end
						end

						# Define the class.
						klass = self.object_type.split(" ")[0]
						class_body =
							"class ::#{klass} < ::MacroDeck::Model
								#{properties}
								#{validations}
							end"
						Kernel.eval(class_body)
					else
						raise "DataObjectDefinition #{self.object_type} is invalid!"
					end
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

				# Returns true if the validations array looks visibly valid. A validation is [ "validates_blah", :field, { args } ].
				def validate_validations
					if self.validations.is_a?(Array)
						if self.validations.length == 0
							return true
						else
							self.validations.each do |validation|
								if validation.is_a?(Array) && validation.length == 3 &&
									validation[0].is_a?(String) && validation[0] =~ /^validates_/ &&
									(validation[1].is_a?(Symbol) || validation[1].is_a?(String)) && # TODO: Validate the field exists.
									validation[2].is_a?(Hash)
									return true
								elsif validation.is_a?(Array) && validation.length == 2 &&
									validation[0].is_a?(String) && validation[0] =~ /^validates_/ &&
									(validation[1].is_a?(Symbol) || validation[1].is_a?(String)) # TODO: Validate the field exists.
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
	end
end
