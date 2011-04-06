# TODO: documentation for this class.
module MacroDeck
	module PlatformSupport
		module DataObject
			def self.included(base)
				base.property :path,		:type => ["String"]	# An array containing where this object sits in the tree. See <http://wiki.apache.org/couchdb/How_to_store_hierarchical_data>.
				base.property :tags,		:type => ["String"]	# FINALLY! Easy tags. This is also an array.
				base.property :created_by,	:type => "String"	# The ID of the author of the item.
				base.property :updated_by,	:type => "String"	# The ID of the updater of the item.
				base.property :owned_by,	:type => "String"	# The ID of the owner of the item.
				base.property :title,		:type => "String"
				base.property :description,	:type => "String"
				base.property :human_id,	:type => "String"	# A human-readable identifier. Was called url_part in the old platform.
				base.property :created_at,	:type => "String", :read_only => true, :protected => true	# ISO8601 date
				base.property :updated_at,	:type => "String", :read_only => true, :protected => true	# ISO8601 date

				# Timestamp callback
				base.set_callback :save, :before do |obj|
					write_attribute "updated_at", Time.now.getutc.iso8601
					write_attribute "created_at", Time.now.getutc.iso8601 if obj.new?
				end

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
								for (i = 0; i <= doc.path.length; i++) {
									var path_and_tag = doc.path.slice(0, i);
									path_and_tag.push(tag);
									emit(path_and_tag, 1);
								}
							});
						}
					}",
					:reduce => "_count"
				}

				# Return the key as the path and the value as 1 for
				# proper reduction. Use include_docs to get the docs.
				# Reduce to return the number of items under a given path.
				# Also path DOES include the current element.
				base.view_by :path, {
					:map =>
					"function(doc) {
						if (doc.path && doc['couchrest-type'] && (doc['couchrest-type'] == #{base.name.to_s.inspect} || #{base.name.to_s.inspect} == 'DataObject' ) ) {
							emit(doc.path, 1);
						}
					}",
					:reduce => "_count"
				}
				# Same as above but the last path item has the title inserted so that it alphabetizes.
				base.view_by :path_alpha, {
					:map =>
					"function(doc) {
						if (doc.path && doc['couchrest-type'] && (doc['couchrest-type'] == #{base.name.to_s.inspect} || #{base.name.to_s.inspect} == 'DataObject' ) ) {
							path = eval(doc.path.toSource());
							path[path.length - 1] = doc.title + '/' + path[path.length - 1];
							emit(path, 1);
						}
					}",
					:reduce => "_count"
				}

				# Add a view on DataObject only that lets you look up an ID and get the type.
				if base.name.to_s == "DataObject"
					base.view_by :id, {
						:map =>
						"function(doc) {
							emit(doc['_id'], doc['couchrest-type']);
						}"
					}
				end
				
				# Validations that happen on this class.
				base.validates_presence_of :path
				base.validates_presence_of :tags
				base.validates_presence_of :created_by
				base.validates_presence_of :updated_by
				base.validates_presence_of :owned_by
				base.validates_length_of :path, :minimum => 1
			end

			# Returns an array containing types of parent objects.
			#
			# An example might be:
			#
			#   [ ["Country", "country-id"], ["Region", "region-id"], ["Locality", "locality-id"] ]
			#
			# You'd use this to, for example, determine the URL to an object.
			def expanded_path
				ids = self.path.dup # CouchRest bug that overwrites path sometimes.
				ids.pop # Last item will be self, and we can fill that in automagically.

				# Use ::DataObject explicitly to make things work in subclasses.
				result = ::DataObject.view("by_id", :reduce => false, :include_docs => false, :keys => ids)
				if result["rows"]
					exp_path = result_rows.collect { [ r["key"], r["value"] ] }
				end

				# Add this item's info.
				exp_path << [ self["couchrest-type"], self["_id"] ]

				return exp_path
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

			# Returns the latitude of this object (if geo is set)
			def lat
				if !self["geo"].nil? && self["geo"].length == 2
					return self["geo"][0]
				else
					return nil
				end
			end

			# Returns the longitude of this object (if geo is set)
			def lng
				if !self["geo"].nil? && self["geo"].length == 2
					return self["geo"][1]
				else
					return nil
				end
			end
		end
	end
end
