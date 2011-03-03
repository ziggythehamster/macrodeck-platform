# Mixin to handle introspection within a class.
# Intended use is to pass in a field name and information about that field
# that we can't automatically determine.

module MacroDeck
	module Introspection
		def self.included(base)
			base.extend(ClassMethods)
		end

		module ClassMethods
			# Pass in +field_name+ and a hash with any of the following options:
			#   +:title+ - human-readable title of the field.
			#   +:description+ - human-readable description of the field.
			#   +:internal+ - set true if this field isn't to appear to an average user.
			#   +:priority+ - sets the priority of the field. Higher = more priority.
			def introspect(field_name, meta)
				@introspections ||= {}
				@introspections[field_name.to_sym] ||= {}
				@introspections[field_name.to_sym].merge!(meta)

				if meta[:priority]
					@fields_by_priority ||= {}
					@fields_by_priority[meta[:priority].to_i] ||= []
					@fields_by_priority[meta[:priority].to_i] << field_name.to_sym
				end
			end

			# Returns the list of introspections.
			def introspections
				@introspections
			end

			# Returns the list of fields by priority as an array. The output looks like this:
			#   [
			#     [ priority, [ fields ] ]
			#   ]
			def fields_by_priority
				if @fields_by_priority
					return @fields_by_priority.sort.reverse
				else
					return nil
				end
			end

			# Returns a human name for the attribute
			def human_attribute_name(attribute)
				if self.introspections && self.introspections[attribute.to_sym] && self.introspections[attribute.to_sym][:title]
					return self.introspections[attribute.to_sym][:title]
				else
					return attribute.to_s
				end
			end
		end
	end
end
