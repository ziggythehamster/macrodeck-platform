# This class contains the definitions for the MacroDeck Platform provided data
# objects. Remember that DataObject provides some base fields.
module MacroDeck
	class PlatformDataObjects
		class << self
			# Returns an array of the objects defined here.
			def objects
				["country", "region", "locality", "place"]
			end
			
			# A country is a simple object. The name of the
			# country is stored in title (provided by DataObject)
			# and the abbreviation is required and must be two
			# characters long. Possible other values include
			# a geographic polygon describing the country.
			def country
				{
					"object_type" => "Country",
					"fields" => [
						["abbreviation", "String", true]
					],
					"validations" => [
						["validates_length_of", "abbreviation", { "is" => 2 }]
					]
				}.freeze
			end

			# A region is a state, province, etc. We're calling it
			# region because that's what the Address microformat
			# calls a state. The name of the state/region is stored
			# in the title, and the abbreviation is stored in
			# abbreviation. Abbreviation is not required (but it
			# should be!) because I'm not sure if _every_ country
			# has regions with abbreviations. Another possible
			# value might be a polygon that represents the region.
			def region
				{
					"object_type" => "Region",
					"fields" => [
						["abbreviation", "String", false]
					],
					"validations" => []
				}.freeze
			end

			# A locality is a city, town, etc. The address microformat
			# calls it locality, so we are too. The name of the city
			# is stored in the title.
			def locality
				{
					"object_type" => "Locality",
					"fields" => [],
					"validations" => []
				}.freeze
			end

			# A place is a place within a locality. This has the most
			# fields of anything.. see below for more info.
			def place
				{
					"object_type" => "Place",
					"fields" => [
						["address", "String", false],
						["postal_code", "String", false],
						["phone_number", "String", false],
						["url", "String", false],
						["geo", "Array", false], # [lat,lng]
						["cuisine", "String", false],
						["features", "Array", false],
						["parking", "String", false],
						["hours", "Hash", false]
					],
					"validations" => []
				}.freeze
			end

			# Run this to define all of the objects.
			def define!
				self.objects.each do |obj|
					puts "Processing #{obj}"

					# Get the definition
					definition = self.send(obj.to_sym)

					# Check if the definition exists.
					check_definition = ::DataObjectDefinition.view("by_object_type", :key => definition.object_type)
					if check_definition.length == 1
						puts "Deleting..."
						check_definition.delete
					elsif check_definition.length > 1
						puts "MORE THAN ONE EXISTS WTF!"
					end

					new_definition = ::DataObjectDefinition.new(definition)
					new_definition.save
					puts "Saved."
				end
			end
		end
	end
end
