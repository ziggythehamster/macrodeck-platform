# Search functionality additions to CouchRest.
# <http://intridea.com/2009/9/20/couchdb-lucene-couchdbx-and-couchrest?blog=company>

require "couchrest"

class CouchRest::Database
	def search(design, index, query, options={})
		CouchRest.get CouchRest.paramify_url("#{@root}/_fti/_design/#{design}/#{index}", options.merge(:q => query))
	end
end

class CouchRest::ExtendedDocument
	def self.search(index, query, options={})
		options[:include_docs] = true
		ret = self.database.search(self.to_s, index, query, options)
		ret['rows'].collect!{|r| self.new(r['doc'])}
		ret
	end
end
