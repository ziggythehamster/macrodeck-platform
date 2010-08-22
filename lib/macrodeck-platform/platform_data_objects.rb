# This class contains the definitions for the MacroDeck Platform provided data
# objects. Remember that DataObject provides some base fields.
module MacroDeck
	class PlatformDataObjects
		class << self
			# Returns an array of the objects defined here.
			def objects
				["country", "region", "locality", "neighborhood", "place", "event"].freeze
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
			# is stored in the title, so we require a title.
			def locality
				{
					"object_type" => "Locality",
					"fields" => [],
					"validations" => [
						["validates_presence_of", "title"] 
					]
				}.freeze
			end

			# A neighborhood is a part of a city, town, etc. In Tulsa,
			# you might have Brookside, Blue Dome District, Woodland Hills,
			# Tulsa Hills, etc.
			def neighborhood
				{
					"object_type" => "Neighborhood",
					"fields" => [],
					"validations" => [
						["validates_presence_of", "title"]
					]
				}.freeze
			end

			# An event is something happening. +event_type+ specifies what
			# kind of event (party, special, band, etc.). The rest are fairly
			# self explanitory.
			def event
				{
					"object_type" => "Event",
					"fields" => [
						["start_time", "Time", true],
						["end_time", "Time", false],
						["recurrence", "Symbol", false]
					],
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
						["geo", ["Float"], false], # [lat,lng]
						["fare", ["String"], false],
						["features", ["String"], false],
						["parking", "String", false],
						["hours", "Hash", false],
						["atmosphere", "String", false],
						["alcohol", ["String"], false],
						["credit_cards_accepted", ["String"], false],
						["reservations", "String", false]
					],
					"validations" => [
						["validates_list_items_in_list", "features",
							{ "allow_nil" => true,
							  "list" => [ 	"Date-Friendly",
									"Kid Friendly",
									"Outdoor Seating",
									"Vegetarian-Friendly",
									"Wi-Fi",
									"Live Music",
									"Delivery",
									"Great Wines" # subjective?
								    ]
							}
						],
						["validates_list_items_in_list", "alcohol",
							{ "allow_nil" => true,
							  "list" => [	"BYO", # Not legal everywhere :(
									"Beer", # Should we split it into Domestic Beer and Imported Beer?
									"Wine",
									"Liquor"
								    ]
							}
						],
						["validates_list_items_in_list", "fare",
							{ "allow_nil" => true,
							  "list" => [	"Modern",
									"Italian",
									"Pizza",
									"American",
									"Dim Sum",
									"Ethiopian",
									"Burgers",
									"Greek",
									"Spanish",
									"Deli",
									"Middle Eastern",
									"Mexican",
									"Brazilian",
									"Tex-Mex",
									"Baked Goods",
									"Japanese",
									"Groceries",
									"French",
									"Korean",
									# "Sweet drinks" # this exists for Koriente but is it a fare?
									"Vietnamese",
									"Thai",
									"Southern",
									"Barbecue",
									"Pan-Asian",
									"Indian",
									"Chinese",
									"Steakhouse",
									"Hawaiian",
									"Tacos", # perhaps not a fare/isn't every Mexican place going to have this?
									"Cal-Mex",
									"Cajun",
									"Russian",
									"Latin American",
									"Irish",
									"Caribbean",
									"Veggie",
									"Sweets", # the above commented-out "Sweet drinks" could go here.
									"Jewish-style deli",
									"Seafood",
									"Indonesian",
									"British",
									"Ice cream",
									"Drinks"
								   ]
							}
						],
						["validates_list_items_in_list", "credit_cards_accepted",
							{ "allow_nil" => true,
							  "list" => [	"Visa",
							  		"MasterCard",
									"American Express",
									"Diner's Club"
								    ]
							}
						]
					],
					"views" => [
						# Makes sure that the only path returned is [country,region,locality,place]
						{ "view_by" => "path_and_type_without_neighborhood",
						  "map" => 
						  "function(doc) {
						  	if (doc.path && doc['couchrest-type'] && doc['couchrest-type'] == 'Place') {
								if (doc.path.length == 4) {
									emit(doc.path, 1); // No neighborhood.
								} else if (doc.path.length == 5) {
									emit([doc.path[0], doc.path[1], doc.path[2], doc.path[4]], 1);
								} else {
									emit(doc.path, 'ERROR');
								}
							}
						   }",
						   "reduce" => "_count"
						},
						# Same as above but alphabetically.
						{ "view_by" => "path_and_type_without_neighborhood_alpha",
						  "map" =>
						  "function(doc) {
						  	if (doc.path && doc['couchrest-type'] && doc['couchrest-type'] == 'Place') {
								if (doc.path.length == 4) {
									doc.path[3] = doc.title + '/' + doc.path[3];
									emit(doc.path, 1);
								} else if (doc.path.length == 5) {
									doc.path[4] = doc.title + '/' + doc.path[4];
									emit([doc.path[0], doc.path[1], doc.path[2], doc.path[4]], 1);
								} else {
									emit(doc.path, 'ERROR');
								}
							}
						   }",
						   "reduce" => "_count"
						}
					]
				}.freeze
			end

			# Run this to define all of the objects.
			def define!
				self.objects.each do |obj|
					# Get the definition
					definition = self.send(obj.to_sym).dup

					# Check if the definition exists.
					check_definition = ::DataObjectDefinition.view("by_object_type", :key => definition["object_type"])
					if check_definition.length == 1
						check_definition[0].destroy
					elsif check_definition.length > 1
						raise "Duplicate definition exists for #{definition['object_type']}"
					end

					new_definition = ::DataObjectDefinition.new(definition)
					new_definition.save
					new_definition.define!
				end
			end
		end
	end
end
