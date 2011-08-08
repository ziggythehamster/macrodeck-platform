# This class contains the definitions for the MacroDeck Platform provided data
# objects. Remember that DataObject provides some base fields.
module MacroDeck
	class PlatformDataObjects
		class << self
			# Returns an array of the objects defined here.
			def objects
				["country", "region", "locality", "neighborhood", "place", "event", "special_photo"].freeze
			end

			# A special photo is a photo of a special (duh!). Turks can use a photo
			# to fill out an Event.
			def special_photo
				{
					"title" => "Special photo",
					"object_type" => "SpecialPhoto",
					"fields" => [],
					"validations" => [],
					"has_attachment" => true,
					"turk_fields" => [
						{ "name" => "DaysOfWeek", "type" => ["Integer#DayOfWeek"] },
						{ "name" => "StartTime", "type" => "Time" },
						{ "name" => "EndTime", "type" => "Time" },
						{ "name" => "Title", "type" => "String", "object_type" => "Event", "object_field" => "title" }
					],
					"turk_tasks" => [
						{
							"id" => "Task_DaysOfWeek",
							"prerequisites" => [],
							"title" => "What days of the week are shown in the photo?",
							"turk_field" => "DaysOfWeek",
							"answer_count" => 0
						},
						{
							"id" => "Task_StartTime",
							"prerequisites" => ["Task_DaysOfWeek"],
							"title" => "What time does the event on $$DaysOfWeek$$ start?",
							"turk_field" => "StartTime",
							"answer_count" => 0
						},
						{
							"id" => "Task_EndTime",
							"prerequisites" => ["Task_DaysOfWeek"],
							"title" => "What time does the event on $$DaysOfWeek$$ end?",
							"turk_field" => "EndTime",
							"answer_count" => 0
						},
						{
							"id" => "Task_Title",
							"prerequisites" => ["Task_DaysOfWeek", "Task_StartTime"],
							"title" => "What is the title for the event on $$DaysOfWeek$$ at $$StartTime$$?",
							"turk_field" => "Title",
							"answer_count" => 0
						}
					]
				}
			end

			# A country is a simple object. The name of the
			# country is stored in title (provided by DataObject)
			# and the abbreviation is required and must be two
			# characters long. Possible other values include
			# a geographic polygon describing the country.
			def country
				{
					"title" => "Country",
					"object_type" => "Country",
					"fields" => [
						["abbreviation", "String", true, "Abbreviation"]
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
					"title" => "State",
					"object_type" => "Region",
					"fields" => [
						["abbreviation", "String", false, "Abbreviation"]
					],
					"validations" => []
				}.freeze
			end

			# A locality is a city, town, etc. The address microformat
			# calls it locality, so we are too. The name of the city
			# is stored in the title, so we require a title.
			def locality
				{
					"title" => "City",
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
					"title" => "Neighborhood",
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
					"title" => "Happening",
					"object_type" => "Event",
					"fields" => [
						["start_time", "Time", true, "Start time"],
						["end_time", "Time", false, "End time"],
						["recurrence", "String", false, { "title" => "Recurrence", "internal" => true }],
						["event_type", "String", false, "Event type"],
						["bitly_hash", "String", false, { "title" => "Bit.ly hash", "internal" => true }],
						["place", "Hash", false, { "title" => "Place information", "internal" => true }]
					],
					"fulltext" => [
						["common_fields",
							{ "index" =>
							  "function(doc) {
								if (doc['couchrest-type'] == 'Event') {
									/*! include iso8601.js */
									var dtstart = parseISO8601(doc.start_time);
									var res = new Document();
									res.add(doc.title, { \"boost\":2.0 });
									res.add(doc.description, { \"boost\":1.5 });
									res.add(doc.event_type);
									if (doc.place) {
										res.add(doc.place.title);
										res.add(doc.place.address);

									}
									res.add(new Date(), { \"field\":\"indexed_at\", \"store\":\"yes\" });
									res.add(new Date(dtstart.getTime()), { \"field\":\"start_time\", \"store\":\"yes\" });
									res.add(doc.path.join('/'), { \"field\":\"path\", \"store\":\"yes\", \"index\":\"not_analyzed\" });
									return res;
								}
							  }"
							}
						]
					],
					"validations" => [
						["validates_presence_of", "title"],
						["validates_list_items_in_list", "event_type",
							{ "allow_nil" => true,
							  "list" => [	"Drink Special",
									"Food and Drink Special",
									"Food Special",
									"Entertainment",
									"Featured",
									"Event"
								    ]
							}
						],
						["validates_list_items_in_list", "recurrence",
							{ "allow_nil" => true,
							  "list" => [ "weekly", "monthly", "none", "yearly", "monthly_nth_nday" ]
							}
						]
					],
					"views" => [
						# Remove the neighborhood and place, replace ID with time.
						# indexes:
						# 0 = country_id
						# 1 = region_id
						# 2 = locality_id
						# 3 = neighborhood_id or place_id or event_id
						# 4 = place_id or event_id
						# 5 = event_id or not present
						# lengths:
						# 6 = neighborhood, place, and city
						# 5 = neighborhood and city, or place w/o hood and city
						# 4 = city only
						{ "view_by" => "path_without_place_or_neighborhood_with_time",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && doc['start_time'] && !doc['end_time']) {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], doc.start_time];
									emit(new_path, 1);
								}
							} else if (doc['couchrest-type'] == 'Event' && doc['start_time'] && doc['end_time']) {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], doc.start_time, doc.end_time];
									emit(new_path, 1);
								}
							}
						  }",
						  "reduce" => "_count"
						},
						# Same as above but end time.
						{ "view_by" => "path_without_place_or_neighborhood_with_end_time",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && doc['end_time']) {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], doc.end_time];
									emit(new_path, 1);
								}
							} else if (doc['couchrest-type'] == 'Event' && !doc['end_time']) {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], doc.start_time];
									emit(new_path, 1);
								}
							}
						  }",
						  "reduce" => "_count"
						},
						# Same as above, but leave the hood and add the title instead of the time.
						{ "view_by" => "path_without_place_alpha",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event') {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], doc.path[3], doc.title];
									emit(new_path, 1);
								}
							}
						  }",
						  "reduce" => "_count"
						},
						# Same as above but with the time at the end (start and end, or just start)
						{ "view_by" => "path_without_place_with_time",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && doc['start_time'] && !doc['end_time']) {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], doc.path[3], doc['start_time']];
									emit(new_path, 1);
								}
							} else if (doc['couchrest-type'] == 'Event' && doc['start_time'] && doc['end_time']) {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], doc.path[3], doc['start_time'], doc['end_time']];
									emit(new_path, 1);
								}
							}
						  }",
						  "reduce" => "_count"
						},
						# Same as above but with end time at the end.
						{ "view_by" => "path_without_place_with_end_time",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && doc['end_time']) {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], doc.path[3], doc['end_time']];
									emit(new_path, 1);
								}
							} else if (doc['couchrest-type'] == 'Event' && !doc['end_time']) {
								if (doc.path.length == 6 || doc.path.length == 5 || doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1],  doc.path[2], doc.path[3], doc['start_time']];
									emit(new_path, 1);
								}
							}
						  }",
						  "reduce" => "_count"
						},
						# Take the full path but make the last item be the start time.
						{ "view_by" => "path_and_start_time",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && doc['start_time']) {
								var new_path = eval(doc.path.toSource());
								new_path[new_path.length - 1] = doc.start_time;
								emit(new_path, 1);
							}
						  }",
						  "reduce" => "_count"
						},
						# Emits the event type just like tags are emitted.
						{ "view_by" => "event_type",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && doc['event_type']) {
								for (i = 0; i <= doc.path.length; i++) {
									var path_and_event_type = doc.path.slice(0, i);
									path_and_event_type.push(doc['event_type']);
									emit(path_and_event_type, 1);
								}
							}
						  }",
						  "reduce" => "_count"
						},
						# Same as above but also emits the document title for sorting alphabetically. (maybe we want to do it by start_time?)
						{ "view_by" => "event_type_alpha",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && doc['event_type']) {
								for (i = 0; i <= doc.path.length; i++) {
									var path_and_event_type = doc.path.slice(0, i);
									path_and_event_type.push(doc['event_type']);
									path_and_event_type.push(doc['title']);

									// FIXME: Implement this better
									if (doc['event_type'] == 'Food and Drink Special') {
										var key1 = path_and_event_type.slice(0); // dup the array
										var key2 = path_and_event_type.slice(0); // dup the array
										key1[key1.length - 2] = 'Food Special';
										key2[key2.length - 2] = 'Drink Special';
										emit(key1, 1);
										emit(key2, 1);
									} else if (doc['event_type'] == 'Drink Special and Entertainment') {
										var key1 = path_and_event_type.slice(0); // dup the array
										var key2 = path_and_event_type.slice(0); // dup the array
										key1[key1.length - 2] = 'Entertainment';
										key2[key2.length - 2] = 'Drink Special';
										emit(key1, 1);
										emit(key2, 1);
									}

									emit(path_and_event_type, 1);
								}
							}
						  }",
						  "reduce" => "_count"
						},
						# Return events that have a blank bitly_hash.
						{ "view_by" => "missing_bitly_hash",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && !doc['bitly_hash']) {
								emit(doc['_id'], 1);
							}
						  }",
						  "reduce" => "_count"
						},
						# Return events that have a blank place.
						{ "view_by" => "missing_place_info",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Event' && !doc['place']) {
								emit(doc['_id'], 1);
							}
						  }",
						  "reduce" => "_count"
						}
					]
				}.freeze
			end

			# A place is a place within a locality. This has the most
			# fields of anything.. see below for more info.
			def place
				{
					"title" => "Place",
					"object_type" => "Place",
					"fields" => [
						["address", "String", false, { "title" => "Address", "priority" => 10 }],
						["postal_code", "String", false, { "title" => "Postal code", "priority" => 10 }],
						["phone_number", "String", false, { "title" => "Phone number", "priority" => 10 }],
						["url", "String", false, "URL"],
						["geo", ["Float"], false, "Geolocation"], 
						["fare", ["String"], false, "Fare"],
						["features", ["String"], false, "Features"],
						["parking", "String", false, "Parking"],
						["hours", "Hash", false, "Hours"],
						["atmosphere", "String", false, "Atmosphere"],
						["alcohol", ["String"], false, "Alcohol"],
						["credit_cards_accepted", ["String"], false, "Credit cards accepted"],
						["reservations", "String", false, "Reservations"],
						["bitly_hash", "String", false, { "title" => "Bit.ly hash", "internal" => true }],
						["foursquare_venue_id", "String", false, { "title" => "Foursquare venue ID", "internal" => true }],
						["tips", nil, false, "Tips"]
					],
					"fulltext" => [
						["common_fields",
							{ "index" =>
							  "function(doc) {
								if (doc['couchrest-type'] == 'Place') {
									var fares = '';
									fares = doc.fare.join(', ');
									var res = new Document();
									res.add(doc.title, { \"boost\":2.0 });
									res.add(doc.description, { \"boost\":1.5 });
									res.add(fares);
									res.add(doc.address);
									res.add(fares, { \"field\":\"fare\", \"store\":\"yes\" });
									res.add(new Date(), { \"field\":\"indexed_at\", \"store\":\"yes\" });
									res.add(doc.path.join('/'), { \"field\":\"path\", \"store\":\"yes\", \"index\":\"not_analyzed\" });
									return res;
								}
							  }"
							}
						]
					],
					"spatial" => [
						["geocode", "function(doc) {
								if (doc['couchrest-type'] == 'Place') {
									if (doc['geo'] && doc['geo'].length == 2) {
										log('geo on ' + doc['_id'] + ' = ' + doc['geo'][0] + ',' + doc['geo'][1] );
										emit({ type: \"Point\", coordinates: [ doc['geo'][0], doc['geo'][1] ] }, doc['_id']);
									} else {
										log('no geo on ' + doc['_id']);
									}
								}
							    }"]
					],
					"validations" => [
						["validates_list_items_in_list", "features",
							{ "allow_nil" => true,
							  "list" => [ 	"Date-Friendly",
									"Kid Friendly",
									"Outdoor Seating",
									"Vegetarian-Friendly",
									"Vegan Friendly",
									"Gluten-Free Friendly",
									"Happy Hour",
									"Late Night",
									"Wi-Fi",
									"Live Music",
									"Daily Specials",
									"Delivery",
									"Romantic",
									"Waterfront",
									"Street Food",
									"Cash Only", # FIXME: Make items imported set credit_cards_accepted to "None" or something.
									"Great Wines" # subjective?
								    ]
							}
						],
						["validates_list_items_in_list", "alcohol",
							{ "allow_nil" => true,
							  "list" => [	"BYO", # Not legal everywhere :(
									"Beer", # Should we split it into Domestic Beer and Imported Beer?
									"Wine",
									"Liquor",
									"Bar",
									"Sports Bar"
								    ]
							}
						],
						["validates_list_items_in_list", "fare",
							{ "allow_nil" => true,
							  "list" => [	"Modern",
									"Italian",
									"Coffee",
									"Tea",
									"Bakery",
									"Donuts",
									"Bagels",
									"Organic",
									"Gastropub", # ??? WTF ???
									"Filipino",
									"Pizza",
									"Pasta",
									"Diner",
									"Sandwiches",
									"Soups",
									"Irish Pub",
									"American",
									"German",
									"European",
									"Soul",
									"Breakfast",
									"Dim Sum",
									"Ethiopian",
									"African",
									"Moroccan",
									"Burgers",
									"Fast Food",
									"Hot Dogs",
									"Greek",
									"Spanish",
									"Vegetarian",
									"Deli",
									"Middle Eastern",
									"Mediterranean",
									"Buffet",
									"Mexican",
									"Brazilian",
									"Tex-Mex",
									"Tapas",
									"Baked Goods",
									"Japanese",
									"Sushi",
									"Groceries",
									"Southwestern",
									"French",
									"Korean",
									"Sweet drinks",
									"Smoothies",
									"Vietnamese",
									"Pho",
									"Thai",
									"Southern",
									"Barbecue",
									"California",
									"Pan-Asian",
									"Asian",
									"Malaysian",
									"Indian",
									"Chinese",
									"Noodle Shop",
									"Steakhouse",
									"Hawaiian",
									"Tacos", # perhaps not a fare/isn't every Mexican place going to have this?
									"Cal-Mex",
									"Cajun",
									"Russian",
									"Latin American",
									"Irish",
									"Caribbean",
									"Cuban",
									"Veggie",
									"Sweets",
									"Chicken",
									"Jewish-style deli",
									"Seafood",
									"Indonesian",
									"British",
									"Ice cream",
									"Drinks",
									"Bar",
									"International",
									"Pub Food"
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
						{ "view_by" => "path_without_neighborhood",
						  "map" => 
						  "function(doc) {
						  	if (doc.path && doc['couchrest-type'] && doc['couchrest-type'] == 'Place') {
								if (doc.path.length == 4) {
									emit(doc.path, 1);
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
						{ "view_by" => "path_without_neighborhood_alpha",
						  "map" =>
						  "function(doc) {
						  	if (doc.path && doc['couchrest-type'] && doc['couchrest-type'] == 'Place') {
								if (doc.path.length == 4) {
									var path = eval(doc.path.toSource());
									path[3] = doc.title + '/' + path[3];
									emit(path, 1);
								} else if (doc.path.length == 5) {
									var path = eval(doc.path.toSource());
									path[4] = doc.title + '/' + path[4];
									emit([path[0], path[1], path[2], path[4]], 1);
								} else {
									emit(doc.path, 'ERROR');
								}
							}
						   }",
						   "reduce" => "_count"
						},
						# Same as above, but by number of tips.
						{ "view_by" => "path_without_neighborhood_tips",
						  "map" =>
						  "function(doc) {
							/*! include numbers.js */
							if (doc.path && doc['couchrest-type'] && doc['couchrest-type'] == 'Place' && doc.tips) {
								if (doc.path.length == 4) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], zeroPad(doc.tips.length, 3) + '/' + doc.path[3]];
									emit(new_path, doc.tips.length);
								} else if (doc.path.length == 5) {
									var new_path = [doc.path[0], doc.path[1], doc.path[2], zeroPad(doc.tips.length, 3) + '/' + doc.path[4]];
									emit(new_path, doc.tips.length);
								}
							}
						  }",
						  "reduce" => "_count"
						},
						# Emits the path but adds the number of tips to the last component.
						{ "view_by" => "path_and_tips",
						  "map" =>
						  "function(doc) {
							/*! include numbers.js */
							if (doc.path && doc['couchrest-type'] && doc['couchrest-type'] == 'Place' && doc.tips) {
								var new_path = doc.path.slice(0); // make a copy using .slice(0) trick
								new_path[new_path.length - 1] = zeroPad(doc.tips.length, 3) + '/' + new_path[new_path.length - 1];
								emit(new_path, doc.tips.length);
							}
						  }",
						  "reduce" => "_count"
						},
						# Emits the fare just like tags.
						{ "view_by" => "fare",
						  "map" =>
						  "function(doc) {
							if (doc.fare && doc['couchrest-type'] == 'Place') {
								doc.fare.map(function(fare) {
									for (i = 0; i <= doc.path.length; i++) {
										var path_and_fare = doc.path.slice(0, i);
										path_and_fare.push(fare);
										emit(path_and_fare, 1);
									}
								});
							}
						  }",
						  "reduce" => "_count"
						},
						# Same as above but alphabetically.
						{ "view_by" => "fare_alpha",
						  "map" =>
						  "function(doc) {
							if (doc.fare && doc['couchrest-type'] == 'Place') {
								doc.fare.map(function(fare) {
									for(i = 0; i <= doc.path.length; i++) {
										var path_and_fare = doc.path.slice(0, i);
										path_and_fare.push(fare);
										path_and_fare.push(doc.title);
										emit(path_and_fare, 1);
									}
								});
							}
						  }",
						  "reduce" => "_count"
						},
						# Same as above but by number of tips.
						{ "view_by" => "fare_tips",
						  "map" =>
						  "function(doc) {
							/*! include numbers.js */
							if (doc.fare && doc['couchrest-type'] == 'Place' && doc.tips) {
								doc.fare.map(function(fare) {
									for(i = 0; i <= doc.path.length; i++) {
										var path_and_fare = doc.path.slice(0, i);
										path_and_fare.push(fare);
										path_and_fare.push(zeroPad(doc.tips.length, 3) + '/' + doc.title);
										emit(path_and_fare, 1);
									}
								});
							}
						  }",
						  "reduce" => "_count"
						},
						# Return places that have a blank geo.
						{ "view_by" => "missing_geo",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Place' && (!doc['geo'] || doc['geo'].length != 2) ) {
								emit(doc['_id'], 1);
							}
						  }",
						  "reduce" => "_count"
						},
						# Return places that have a blank bitly_hash.
						{ "view_by" => "missing_bitly_hash",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Place' && !doc['bitly_hash']) {
								emit(doc['_id'], 1);
							}
						  }",
						  "reduce" => "_count"
						},
						# Return places that have a blank foursquare_venue_id (and not blank geo)
						{ "view_by" => "missing_foursquare_venue_id",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Place' && !doc['foursquare_venue_id'] && doc['geo']) {
								emit(doc['_id'], 1);
							}
						  }",
						  "reduce" => "_count"
						},
						# Return places with a foursquare_venue_id
						{ "view_by" => "foursquare_venue_id",
						  "map" =>
						  "function(doc) {
							if (doc['couchrest-type'] == 'Place' && doc['foursquare_venue_id']) {
								emit(doc['foursquare_venue_id'], 1);
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

					new_definition = ::DataObjectDefinition.new(definition.dup)
					new_definition.save
					new_definition.define!

					db = CouchRest.database!(MacroDeck::Platform.database_name)

					# Get the design doc.
					doc = db.get("_design/#{definition["object_type"]}")

					if doc
						if definition["fulltext"]
							doc["fulltext"] ||= {}
							definition["fulltext"].each do |ft|
								ftdef = ft[1]
								ftdef["index"] = MacroDeck::Platform.process_includes(ftdef["index"])
								doc["fulltext"][ft[0]] = ftdef
							end
						end
						if definition["spatial"]
							doc["spatial"] ||= {}
							definition["spatial"].each do |sp|
								spdef = sp[1]
								spdef = MacroDeck::Platform.process_includes(spdef)
								doc["spatial"][sp[0]] = spdef
							end
						end
					end

					doc.save
				end
			end
		end
	end
end
