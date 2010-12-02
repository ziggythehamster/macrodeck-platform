# Search functionality additions to CouchRest.
# <http://intridea.com/2009/9/20/couchdb-lucene-couchdbx-and-couchrest?blog=company>

require "couchrest"

class CouchRest::Database
	def search(design, index, query, options={})
		CouchRest.get CouchRest.paramify_url("#{@root}/_fti/_design/#{design}/#{index}", options.merge(:q => query))
	end

	# Perform a spatial search. +bbox+ should be specified as an array.
	def spatial_search(design, index, bbox, options={})
		CouchRest.get CouchRest.paramify_url("#{@root}/_design/#{design}/_spatial/#{index}", options.merge(:bbox => bbox.join(",")))
	end
end

class CouchRest::ExtendedDocument
	def self.search(index, query, options={})
		options[:include_docs] = true
		ret = self.database.search(self.to_s, index, query, options)
		ret['rows'].collect!{|r| self.new(r['doc'])}
		ret
	end

	# Perform a spatial search. +bbox+ should be specified as an array.
	def self.spatial_search(index, bbox, options={})
		result = self.database.spatial_search(self.to_s, index, bbox, options)
		ret = []
		if result['rows']
			result['rows'].each do |res|
				ret << self.get(res['id'])
			end
		end
		return ret
	end

	# Perform a proximity search. Returns an array of arrays where the first index
	# in the array item is the distance and the second is the data object.
	#
	# FIXME: Add an option to allow specifying the radius of Earth, to allow
	# for distances in km and other units.
	def self.proximity_search(index, lat, lng, radius, options={})
		bbox = GeospatialObject.bounding_box(lat, lng, radius)
		center = GeospatialObject.new([lat, lng])
		result = self.database.spatial_search(self.to_s, index, bbox, options)

		ret = []
		if result['rows']
			result['rows'].each do |res|
				gs_obj = GeospatialObject.new(self.get(res['id']))
				ret << gs_obj.to_sortable_array(center)
			end
		end
		return ret.sort
	end
end
