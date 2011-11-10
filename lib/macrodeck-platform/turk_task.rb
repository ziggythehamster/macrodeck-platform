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

		# Add a method to the instance that allows us to use the TurkTask as
		# a surrogate for DataObject in behaviors.
		field_name = @field["name"] # to be accessible below.
		field_type = @field["type"]
		(class << self; self; end).class_eval do
			if field_type.respond_to?(:length) && field_type.length == 1 # not checking for is_a?(Array); instead seeing if it is one element long. Highly unlikely a string type will be a single byte long.
				define_method field_name.to_sym do
					[]
				end
			else
				define_method field_name.to_sym do
					nil
				end
			end
		end
	end

	# This method is required to make this class work as a replacement for DataObject in behaviors.
	def self.human_attribute_name(attr)
		if attr.to_s == @field["name"].to_s
			if @field["title"].nil?
				@field["name"].to_s
			else
				@field["title"].to_s
			end
		else
			attr.to_s
		end
	end
end
