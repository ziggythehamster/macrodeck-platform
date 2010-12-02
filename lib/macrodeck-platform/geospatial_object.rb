# This class is a simple "wrapper" class to perform geospatial math and distance calculation.
class GeospatialObject
	attr_reader :data_object

	# GeospatialObject must be created with a passed data_object.
	def initialize(data_object)
		@data_object = data_object
	end

	# Returns the latitude of the data object.
	def lat
		@data_object.lat
	end

	# Returns the longitude of the data object.
	def lng
		@data_object.lng
	end

	# Return the distance to the passed object.
	#
	# Pass the earth's radius as well if you need it in km instead
	# of miles.
	#
	# Ported from: <http://www.movable-type.co.uk/scripts/latlong.html>
	def distance_to(geospatial_object, earth_radius = 3963.1676)
		diff_lat = (geospatial_object.lat - self.lat).to_radians
		diff_lng = (geospatial_object.lng - self.lng).to_radians
		a = Math.sin(diff_lat/2)**2 +
			Math.cos(self.lat.to_radians) * Math.cos(geospatial_object.lat.to_radians) *
			Math.sin(diff_lng/2)**2
		c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
		d = earth_radius * c
		return d
	end

	# Returns an array that consists of [distance, data_object] for sorting.
	# Pass in the geospatial object that you want to use to get the distance.
	def to_sortable_array(geospatial_object)
		[self.distance_to(geospatial_object), @data_object]
	end
end
