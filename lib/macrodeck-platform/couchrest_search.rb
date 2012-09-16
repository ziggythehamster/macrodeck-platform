# Search functionality additions to CouchRest.
# <http://intridea.com/2009/9/20/couchdb-lucene-couchdbx-and-couchrest?blog=company>

require "couchrest"

class CouchRest::Database
	def search(design, index, query, options={})
		# This is the old syntax for the non-proxied version of CouchDB Lucene.
		#CouchRest.get CouchRest.paramify_url("#{@root}/_fti/_design/#{design}/#{index}", options.merge(:q => query))
		CouchRest.get CouchRest.paramify_url("#{@host}/_fti/local/#{@name.gsub('/','%2F')}/_design/#{design}/#{index}", options.merge(:q => query)
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
		res_ids = []
		if result['rows']
			result['rows'].each do |res|
				res_ids << res['id']
			end
			if res_ids.length > 0
				# Chop off some if needed.
				res_ids = res_ids[0..options[:limit].to_i] if options[:limit]

				docs = ::DataObject.database.get_bulk(res_ids)
				if docs["rows"]
					ret = docs["rows"].collect { |d| ::DataObject.create_from_database(d["doc"]) }
				end
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
		res_ids_with_dist = []
		res_ids = []
		if result['rows']
			result['rows'].each do |res|
				gs_obj = GeospatialObject.new([res["bbox"][0], res["bbox"][1]])
				res_ids_with_dist << [ gs_obj.distance_to(center), res["id"] ]
			end
			if res_ids_with_dist.length > 0
				res_ids_with_dist.sort_by { |r| r[0] }
				res_ids = res_ids_with_dist.collect { |r| r[1] }

				# If the :limit option is passed in, trim it to that many results
				res_ids = res_ids[0..options[:limit].to_i] if options[:limit]

				docs = ::DataObject.database.get_bulk(res_ids)
				if docs["rows"]
					ret = docs["rows"].collect { |d| ::DataObject.create_from_database(d["doc"]) }
				end
			end
		end
		return ret
	end
end
