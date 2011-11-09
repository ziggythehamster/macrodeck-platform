class TurkTask
	attr_reader :id
	attr_reader :prerequisites
	attr_reader :title
	attr_reader :answer_count
	attr_reader :field
	attr_reader :show_fields
	attr_reader :field_behavior

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

		if @field["type"].is_a?(Array)
			if @field["type"][0].include?("#")
				@field_behavior = @field["type"][0].split("#")[1]
			else
				@field_behavior = @field["type"][0]
			end
		else
			if @field["type"].include?("#")
				@field_behavior = @field["type"].split("#")[1]
			else
				@field_behavior = @field["type"]
			end
		end

		# Now tack on MacroDeck:: and Behavior.
		@field_behavior = "MacroDeck::#{@field_behavior}Behavior"
	end
end
