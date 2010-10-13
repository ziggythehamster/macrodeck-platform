# This monkey patch is needed because for some reason, CouchDB requires
# reduction parameters to be at the beginning of the query string

def CouchRest
	class << self
		def paramify_url url, params = {}
			if params && !params.empty?
				prequery = []
				prequery << "reduce=#{CGI.escape(params.delete[:reduce].to_s)}" if params.include? :reduce
				prequery << "group=#{CGI.escape(params.delete[:group].to_s)}" if params.include? :group
				prequery << "group_level=#{CGI.escape(params.delete[:group_level].to_s)}" if params.include? :group_level
				prequery = prequery.join("&")
				prequery << "&" if prequery.length > 0 # needed so that query and prequery go together.
				query = params.collect do |k,v|
					v = v.to_json if %w{key startkey endkey}.include?(k.to_s)
					"#{k}=#{CGI.escape(v.to_s)}"
				end.join("&")
				url = "#{url}?#{prequery}#{query}"
			end
			url
		end
	end
end
