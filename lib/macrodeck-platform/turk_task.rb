class TurkTask
	attr_reader :item
	attr_reader :task
	attr_reader :field

	def initialize(item, task)
		@item = item
		@task = task
		@item.turk_fields.each do |tf|
			if tf["name"] == @task.turk_field
				@field = tf
			end
		end
	end
end
