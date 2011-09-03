# This class handles a data object definition record. When objects are defined,
# a class inheriting from DataObject is created. The actual class is created in
# platform.rb because we can't specify the database name at runtime in another
# way.
module MacroDeck
	module PlatformSupport
		module DataObjectDefinition
			def self.included(base)
				base.unique_id :object_type
				base.property :object_type,	:type => "String"
				base.property :fields
				base.property :validations
				base.property :views
				base.property :fulltext
				base.property :title	# Used with introspection

				base.view_by :object_type

				base.send(:attr_reader, :defined)
                                
				# Validations that happen on this class.
				base.validates_presence_of :object_type
				base.validates_presence_of :fields
				base.validates_presence_of :validations
				base.validates_true_for :object_type, :logic => lambda { object_type.is_a?(String) }
				base.validates_true_for :fields, :logic => :validate_fields, :message => "is not valid"
				base.validates_true_for :validations, :logic => :validate_validations, :message => "is not valid"
				base.validates_true_for :views, :logic => :validate_views, :message => "is not valid"
			end

			# Executes the code necessary to define this object
			def define!
				properties = ""
				validations = ""
				views = ""
				class_body = ""

				@defined = false if @defined.nil?

				unless @defined
					@defined = true

					# Populate properties.
					if self.valid?
						# Iterate all of the fields and define them.
						self.fields.each do |field|
							symbol = field[0].to_sym.inspect
							klass = field[1].inspect
							if field[1].nil?
								properties << "property #{symbol}\n"
							else
								properties << "property #{symbol}, :type => #{klass}\n"
							end
							properties << "validates_presence_of #{symbol}\n" if field[2] == true

							if field[3] && field[3].is_a?(String)
								properties << "introspect #{symbol}, :title => #{field[3].inspect}\n"
							elsif field[3] && field[3].is_a?(Hash)
								title = field[3]["title"]
								priority = field[3]["priority"]
								internal = field[3]["internal"]
								desc = field[3]["description"]
								properties << "introspect #{symbol}, :title => #{title.inspect}, :description => #{desc.inspect}, :priority => #{priority.inspect}, :internal => #{internal.inspect}\n"
							end
						end

						# Iterate the validations and define them.
						self.validations.each do |validation|
							symbol = validation[1].to_sym.inspect
	
							if validation.length == 3
								# Build the validation if arguments are required
								args = {}
								validation[2].each_pair do |key, value|
									args[key.to_sym] = value
								end
								validations << "#{validation[0].to_s} #{symbol}, #{args.inspect}\n"
							elsif validation.length == 2
								# Build the validation if arguments aren't required.
								validations << "#{validation[0].to_s} #{symbol}\n"
							end
						end

						# Iterate the views and define them.
						unless self.views.nil?
							self.views.each do |view|
								symbol = view["view_by"].to_sym.inspect
								new_hash = { :map => MacroDeck::Platform.process_includes(view["map"]), :reduce => MacroDeck::Platform.process_includes(view["reduce"]) }
								views << "view_by #{symbol}, #{new_hash.inspect}\n"
							end
						end

						# Define the class.
						klass = self.object_type.split(" ")[0]
						class_body =
							"class ::#{klass} < ::DataObject
								include ::MacroDeck::PlatformSupport::DataObject
								include ::MacroDeck::Introspection
								include ::MacroDeck::TurkSupport

								#{properties}
								#{validations}
								#{views}
							end"
						Kernel.eval(class_body)
						Kernel.eval("::#{klass}.save_design_doc!")
					else
						raise "DataObjectDefinition #{self.object_type} is invalid!"
					end
				end
			end

			private
				# Returns true if the views array looks valid.
				# Should be an array of hashes like this:
				#    [ { "view_by" => "name_of_view", "map" => "map_function", "reduce" => "reduce_function" }, { ... } ]
				def validate_views
					if self.views.is_a?(Array)
						if self.views.length == 0
							return true
						else
							valid = false
							self.views.each do |view|
								if view.is_a?(Hash) && !view["view_by"].nil? && !view["map"].nil? && !view["reduce"].nil?
									valid = true
								else
									valid = false
								end
							end
							return valid
						end
					else
						if self.views.nil?
							return true
						else
							return false
						end
					end
				end

				# Returns true if the fields array is at least visibly valid.
				# We won't know for sure since we don't check every detail.
				def validate_fields
					if self.fields.is_a?(Array)
						if self.fields.length == 0
							return true
						else
							valid = false
							self.fields.each do |field|
								if field.is_a?(Array) && (field.length == 3 || field.length == 4) && field[0].is_a?(String) && (field[1].is_a?(String) || field[1].is_a?(Array) || field[1].is_a?(NilClass)) && (field[2].is_a?(TrueClass) || field[2].is_a?(FalseClass))
									valid = true
								else
									valid = false
								end
							end
							return valid
						end
					else
						return false
					end
				end

				# Returns true if the validations array looks visibly valid. A validation is [ "validates_blah", :field, { args } ].
				def validate_validations
					if self.validations.is_a?(Array)
						if self.validations.length == 0
							return true
						else
							valid = false
							self.validations.each do |validation|
								if validation.is_a?(Array) && validation.length == 3 &&
									validation[0].is_a?(String) && validation[0] =~ /^validates_/ &&
									(validation[1].is_a?(Symbol) || validation[1].is_a?(String)) && # TODO: Validate the field exists.
									validation[2].is_a?(Hash)
									valid = true
								elsif validation.is_a?(Array) && validation.length == 2 &&
									validation[0].is_a?(String) && validation[0] =~ /^validates_/ &&
									(validation[1].is_a?(Symbol) || validation[1].is_a?(String)) # TODO: Validate the field exists.
									valid = true
								else
									valid = false
								end
							end
							return valid
						end
					else
						return false
					end
				end
		end
	end
end
