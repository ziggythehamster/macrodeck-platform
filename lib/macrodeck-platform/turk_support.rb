# This mixin makes the different turk-related
# settings accessible via the Rails object.

module MacroDeck
	module TurkSupport
		def self.included(base)
			base.property :turk_responses, "Hash"

			base.extend ClassMethods
		end

		# Returns a list of pending turk tasks.
		def pending_turk_tasks
			if self.class.respond_to?(:turk_tasks) && self.respond_to?(:turk_responses)
				if @pending_turk_tasks.nil?
					@pending_turk_tasks = []
					unsatisfied_tasks = []
					value_map = {}

					self.class.turk_tasks.each do |task|
						# Check if an answer has been saved for this task's field.
						# If an answer has been provided, don't add it to the list.
						# If an answer has not been provided, check that it can be answered.

						if self.turk_responses[task.field["name"]].nil?
							unsatisfied_tasks << task.id
							if task.prerequisites.nil? || task.prerequisites.length == 0
								# We can answer this immediately.
								@pending_turk_tasks << [ task, task.title ]
							else
								# Check prerequisites
								prereq_met = true
								task.prerequisites.each do |prereq|
									prereq_met = false if unsatisfied_tasks.include? prereq
								end

								# TODO: If prerequisites met, replace the $$FieldName$$ that appear. 
							end
						else
							# TODO: Store an entry in value_map for this response. I imagine it'll be something like:
							#
							# {
							#     "DaysOfWeek=1" => {
							#         "StartTime" => x,
							#         "EndTime" => x
							#         "Title" => x
							#     }
							# }
							#
							# Basically, if a field is an array, its value will be added to the key, so we can get a tree of
							# answers that go with a particular element in the array.
							#
							# At least, that's what makes sense right now. I dunno for sure if that'll work though.
						end
					end
				else
					return @pending_turk_tasks
				end
			else
				return nil
			end
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
