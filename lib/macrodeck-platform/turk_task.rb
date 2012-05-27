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
		@field = nil
		obj.turk_fields.each do |tf|
			if tf["name"] == task["turk_field"]
				@field = tf
			end
		end
		raise "Turk task #{task["title"]} does not specify a valid field!" if @field.nil?
		@field["params"] ||= {} # So there's always params if there aren't any.
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
	def prerequisites_met?(answers, return_root = false)
		if @prerequisites.length == 0
			puts "[#{@id}#prerequisites_met?] Prerequisites met due to no prerequisites."

			if return_root
				return [true, answers]
			else
				return true
			end
		else
			puts "[#{@id}#prerequisites_met?] Checking prerequisites..."
			prereq_met = true
			root = {}

			@prerequisites.each_index do |prereq_index|
				root = answers

				# Check the completion of this branch of prerequisites.
				@prerequisites[0..prereq_index].each do |prereq|
					if !root.nil? && root.key?(prereq) && root[prereq].is_a?(Array)
						puts "[#{@id}#prerequisites_met?] prereq_index=#{prereq_index} prereq=#{prereq} exists in answers and is an array."
						val = root[prereq][0] # FIXME: Test every possible answer
						root = root["#{prereq}=#{val}"]
					elsif !root.nil? && root.key?(prereq)
						puts "[#{@id}#prerequisites_met?] prereq_index=#{prereq_index} prereq=#{prereq} exists in answers and is not an array."
						root = root["#{prereq}="]
					else
						puts "[#{@id}#prerequisites_met?] prereq_index=#{prereq_index} prereq=#{prereq} does not exist in answers, prerequisites unmet."
						prereq_met = false
					end
				end
			end

			if return_root
				return [prereq_met, root]
			else
				return prereq_met
			end
		end
	end

	# Determine if this question is answered
	def answered?(answers)
		# If there are no prerequisites, this answer will appear in the root.
		if @prerequisites.length == 0
			if answers.nil? || !answers.key?(@id) || answers[@id].nil? || answers[@id].length == 0
				return false
			else
				return true
			end
		else
			prereq_results = prerequisites_met?(answers, true)
			prereq_met = prereq_results[0]

			# If the prerequisites are met, we can check the answer.
			if prereq_met
				if !prereq_results[1].nil? && prereq_results[1].key?(@id) && !prereq_results[1][@id].nil?
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
end
