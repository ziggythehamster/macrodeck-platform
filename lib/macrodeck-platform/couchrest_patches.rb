# Add search_by to CouchRest::Design
class ::CouchRest::Design < ::CouchRest::Document
	def search_by(*keys)
		opts = keys.pop if keys.last.is_a?(Hash)
		opts ||= {}
		self['fulltext'] ||= {}
		method_name = "by_#{keys.join('_and_')}"

		if opts[:index]
			fulltext = {}
			fulltext["index"] = opts.delete(:index)
			if opts[:analyzer]
				fulltext["analyzer"] = opts.delete(:analyzer)
			else
				fulltext["analyzer"] = "standard"
			end
			fulltext["defaults"] = opts.delete(:defaults) if opts[:defaults]
			self["fulltext"][method_name] = fulltext
		else
			raise NotImplementedError, "Please specify an index function."
		end
		method_name
	end
end
