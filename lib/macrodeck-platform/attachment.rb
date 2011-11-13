# An Attachment is an object that represents a file which has been uploaded to
# Amazon S3. Attachment objects will be automatically created when an object's
# attachments array is accessed.
class Attachment
	attr_reader :file_name
	attr_reader :updated_at
	attr_accessor :content_type

	# Pass in the parent object and the hash representing the object in
	# the database.
	def initialize(data_object, attachment_hash)
		@data_object = data_object
		@file_name = attachment_hash[:file_name] || attachment_hash["file_name"]
		@content_type = attachment_hash[:content_type] || attachment_hash["content_type"]
		@updated_at = attachment_hash[:updated_at] || attachment_hash["updated_at"]
		@deleted = false
	end

	# Returns true if deleted, false otherwise.
	def deleted?
		@deleted
	end

	# Deletes this file from the bucket.
	def delete!(access_key, secret_access_key)
		@bucket = MacroDeck::Platform.s3_bucket(access_key, secret_access_key)
		if !@bucket.nil?
			@deleted = true if @bucket.key(self.to_bucket_key).delete
		end

		return @deleted
	end

	# Creates or updates a key in the bucket.
	def update!(access_key, secret_access_key, data)
		@bucket = MacroDeck::Platform.s3_bucket(access_key, secret_access_key)
		if !@bucket.nil?
			if @bucket.key(self.to_bucket_key).put(data)
				@updated_at = Time.now
				return true
			end
		end

		return false
	end

	# Returns a URL to this attachment (pass in access key, secret access key, and when you
	# want the URL to expire)
	def url(access_key, secret_access_key, expires_in)
		@bucket = MacroDeck::Platform.s3_bucket(access_key, secret_access_key)
		if !@bucket.nil?
			@bucket_key = self.to_bucket_key
			return @bucket.s3.interface.get_link(@bucket.name, @bucket_key, expires_in)
		else
			return nil
		end
	end

	# Returns a bucket key.
	def to_bucket_key
		"attachments/#{@data_object.class.to_s.downcase}/#{@data_object.id.to_s.downcase}/#{@file_name.downcase}"
	end

	# Converts this object to a hash.
	def to_hash
		{
			:file_name => @file_name,
			:content_type => @content_type,
			:updated_at => @updated_at
		}
	end
end
