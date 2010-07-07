# TODO: documentation for this class.
module MacroDeck
	module PlatformSupport
		module DataObject
			def self.included(base)
				base.property :path,		:type => ["String"]	# An array containing where this object sits in the tree. See <http://wiki.apache.org/couchdb/How_to_store_hierarchical_data>.
				base.property :tags,		:type => ["String"]	# FINALLY! Easy tags. This is also an array.
				base.property :created_by	# The ID of the author of the item.
				base.property :updated_by	# The ID of the updater of the item.
				base.property :owned_by		# The ID of the owner of the item.
				base.property :title
				base.property :description
				base.property :human_id		# A human-readable identifier. Was called url_part in the old platform.

				# Some basic views.
				base.view_by :created_by
				base.view_by :updated_by
				base.view_by :owned_by
				base.view_by :title
				base.view_by :human_id # this might need special treatment.

				# TODO: Advanced views (tags, path, possibly human_id)

				# Return the tag as the key and the value as 1 to allow for
				# reduction. Use include_docs to retrieve the documents if
				# you need to. The reduce function will count the number of
				# uses of a tag.
				base.view_by :tags, {
					:map => 
					"function(doc) {
						if (doc.tags) {
							doc.tags.map(function(tag) {
								emit(tag, 1);
							});
						}
					}",
					:reduce =>
					"function(key, values, rereduce) {
						return sum(values);
					}"
				}

				# Return the key as the path and the value as 1 for
				# proper reduction. Use include_docs to get the docs.
				# Reduce to return the number of items under a given path.
				# Also path DOES include the current element.
				base.view_by :path, {
					:map =>
					"function(doc) {
						if (doc.path) {
							emit(doc.path, 1);
						}
					}",
					:reduce =>
					"function(key, values, rereduce) {
						return sum(values);
					}"
				}
				
				# Validations that happen on this class.
				base.validates_presence_of :path
				base.validates_presence_of :tags
				base.validates_presence_of :created_by
				base.validates_presence_of :updated_by
				base.validates_presence_of :owned_by
				base.validates_true_for :path,		:logic => lambda { path.is_a?(Array) }
				base.validates_true_for :tags,		:logic => lambda { tags.is_a?(Array) }
				base.validates_true_for :created_by,	:logic => lambda { created_by.is_a?(String) }
				base.validates_true_for :updated_by,	:logic => lambda { updated_by.is_a?(String) }
				base.validates_true_for :owned_by,	:logic => lambda { owned_by.is_a?(String) }
			end

			# Returns the parent of the object. If the object is at the root, this will return [].
			def parent
				parent = self.path.dup
				parent.pop
				return parent
			end

			# Returns the children of this object. Pass true if you want the documents returned as well.
			def children(include_docs = false)
				startkey = self.path.dup
				startkey.push 0
				endkey = self.path.dup
				endkey.push Hash.new
				return ::DataObject.view("by_path", :reduce => false, :startkey => startkey, :endkey => endkey, :include_docs => include_docs)
			end

			# Returns the number of children of this object.
			def children_count
				startkey = self.path.dup
				startkey.push 0
				endkey = self.path.dup
				endkey.push Hash.new
				result = ::DataObject.view("by_path", :reduce => true, :startkey => startkey, :endkey => endkey)
				if result["rows"] == []
					return 0
				else
					return result["rows"][0]["value"]
				end
			end
		end
	end
end
