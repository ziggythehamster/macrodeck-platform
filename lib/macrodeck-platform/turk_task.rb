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
		@data_object = obj

		# Figure out the behavior of the field.
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

		# Store the human attribute name for this field.
		@@human_attribute_names ||= {}
		if @field["title"].nil?
			@@human_attribute_names[@field["name"].to_sym] = @field["name"].to_s
		else
			@@human_attribute_names[@field["name"].to_sym] = @field["title"].to_s
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
		@@human_attribute_names[attr.to_sym]
	end

	# Determine if the prerequisites have been met
	def prerequisites_met?(answers)
		if @prerequisites.length == 0
			return true
		else
			prereq_met = true
			root = answers
			@prerequisites.each do |prereq|
				field_name = @data_object.turk_task_by_id(prereq).field

				if root.key?(field_name) && root[field_name].is_a?(Array)
					val = root[field_name][0]
					root = root["#{field_name}=#{val}"]
				elsif root.key?(field_name)
					root = root["#{field_name}="]
				else
					prereq_met = false
				end
			end

			return prereq_met
		end
	end
end
