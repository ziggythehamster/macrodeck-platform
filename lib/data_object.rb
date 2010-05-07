# TODO: documentation for this class.
module MacroDeck
	module PlatformSupport
		module DataObject
			def self.included(base)
				base.property :path		# An array containing where this object sits in the tree. See <http://wiki.apache.org/couchdb/How_to_store_hierarchical_data>.
				base.property :tags		# FINALLY! Easy tags. This is also an array.
				base.property :created_by	# The ID of the author of the item.
				base.property :updated_by	# The ID of the updater of the item.
				base.property :owned_by		# The ID of the owner of the item.
				base.property :title
				base.property :description
				base.property :human_id		# A human-readable identifier. Was called url_part in the old platform.

				# Some basic views.
				base.view_by :path
				base.view_by :created_by
				base.view_by :updated_by
				base.view_by :owned_by
				base.view_by :title
				base.view_by :human_id # this might need special treatment.

				# TODO: Advanced views (tags, path, possibly human_id)
				
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
		end
	end
end
