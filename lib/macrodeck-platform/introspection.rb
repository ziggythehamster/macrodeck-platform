# Mixin to handle introspection within a class.
# Intended use is to pass in a field name and information about that field
# that we can't automatically determine.

module MacroDeck
	module Introspection
		def included(base)
			base.send(:include, InstanceMethods)
			base.extend(ClassMethods)
		end

		module ClassMethods
			# Pass in +field_name+ and a hash with any of the following options:
			#   +:title+ - human-readable title of the field.
			#   +:description+ - human-readable description of the field.
			#   +:internal+ - set true if this field isn't to appear to an average user.
			def introspect(field_name, meta)
				@introspections ||= []
				@introspections[field_name.to_sym] ||= {}
				@introspections[field_name.to_sym].merge!(meta)
			end
		end

		module InstanceMethods
			# Returns the list of introspections.
			def introspections
				self.class.instance_variable_get("@introspections")
			end
		end
	end
end
