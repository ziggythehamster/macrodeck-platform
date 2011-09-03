# This mixin makes the different turk-related
# settings accessible via the Rails object.

module MacroDeck
	module TurkSupport
		def self.included(base)
			base.extend ClassMethods
		end

		module ClassMethods
			def turk_tasks
				if @turk_tasks.nil?
					@turk_tasks = self.stored_design_doc["turk_tasks"].collect { |task| TurkTask.new(self, task) }
					return @turk_tasks
				else
					return @turk_tasks
				end
			end

			def turk_fields
				return self.stored_design_doc["turk_fields"]
			end
		end
	end
end
