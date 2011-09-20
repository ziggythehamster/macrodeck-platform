class TurkTask
	attr_reader :id
	attr_reader :prerequisites
	attr_reader :title
	attr_reader :answer_count
	attr_reader :field
	attr_reader :show_fields

	def initialize(obj, task)
		# Link the field in both records.
		obj.turk_fields.each do |tf|
			if tf["name"] == task["turk_field"]
				@field = tf
			end
		end
		@id = task["id"]
		@prerequisites = task["prerequisites"]
		@title = task["title"]
		@answer_count = task["answer_count"]
		@show_fields = task["show_fields"]
	end
end
