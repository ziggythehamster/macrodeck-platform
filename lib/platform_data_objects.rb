# This class contains the definitions for the MacroDeck Platform provided data
# objects. Remember that DataObject provides some base fields.
module MacroDeck
	class PlatformDataObjects
		class << self
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
				}
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
				}
			end
		end
	end
end
