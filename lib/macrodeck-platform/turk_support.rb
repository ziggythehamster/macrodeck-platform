# This mixin makes the different turk-related
# settings accessible via the Rails object.

module MacroDeck
	module TurkSupport
		def self.included(base)
			base.extend ClassMethods
		end

		module ClassMethods
			def turk_tasks
				return self.stored_design_doc["turk_tasks"]
			end

			def turk_fields
				return self.stored_design_doc["turk_fields"]
			end
		end
	end
end
