module CouchRest
	class << self
		# This monkey patch is needed because for some reason, CouchDB requires
		# reduction parameters to be at the beginning of the query string
		def paramify_url url, params = {}
			if params && !params.empty?
				prequery = []
				prequery << "reduce=#{CGI.escape(params.delete(:reduce).to_s)}" if params.include? :reduce
				prequery << "group=#{CGI.escape(params.delete(:group).to_s)}" if params.include? :group
				prequery << "group_level=#{CGI.escape(params.delete(:group_level).to_s)}" if params.include? :group_level
				prequery << "startkey=#{CGI.escape(params.delete(:startkey).to_json.to_s)}" if params.include? :startkey
				prequery << "endkey=#{CGI.escape(params.delete(:endkey).to_json.to_s)}" if params.include? :endkey
				prequery = prequery.join("&")
				prequery << "&" if prequery.length > 0 # needed so that query and prequery go together.
				query = params.collect do |k,v|
					v = v.to_json if %w{key}.include?(k.to_s)
					"#{k}=#{CGI.escape(v.to_s)}"
				end.join("&")
				url = "#{url}?#{prequery}#{query}"
			end
			url
		end
	end
end

module CouchRest
	module RestAPI
		def put(uri, doc = nil)
			payload = doc.to_json if doc

			options = {
				:method => :put,
				:url => uri,
				:headers => default_headers,
				:payload => payload
			}

			uri_parsed = URI(uri)
			options[:user] = uri_parsed.user if uri_parsed.user
			options[:password] = uri_parsed.password if uri_parsed.password

			begin
				JSON.parse(RestClient::Request.execute(options))
			rescue Exception => e
				if $DEBUG
					raise "Error while sending a PUT request #{uri}\npayload: #{payload.inspect}\n#{e}"
				else
					raise e
				end
			end
		end

		def get(uri)
			options = {
				:method => :get,
				:url => uri,
				:headers => default_headers
			}

			uri_parsed = URI(uri)
			options[:user] = uri_parsed.user if uri_parsed.user
			options[:password] = uri_parsed.password if uri_parsed.password

			begin
				JSON.parse(RestClient::Request.execute(options), :max_nesting => false)
			rescue => e
				if $DEBUG
					raise "Error while sending a GET request #{uri}\n: #{e}"
				else
					raise e
				end
			end
		end

		def post(uri, doc = nil)
			payload = doc.to_json if doc

			options = {
				:method => :post,
				:url => uri,
				:headers => default_headers,
				:payload => payload
			}

			uri_parsed = URI(uri)
			options[:user] = uri_parsed.user if uri_parsed.user
			options[:password] = uri_parsed.password if uri_parsed.password

			begin
				JSON.parse(RestClient::Request.execute(options))
			rescue Exception => e
				if $DEBUG
					raise "Error while sending a POST request #{uri}\npayload: #{payload.inspect}\n#{e}"
				else
					raise e
				end
			end
		end

		def delete(uri)
			options = {
				:method => :delete,
				:url => uri,
				:headers => default_headers
			}

			uri_parsed = URI(uri)
			options[:user] = uri_parsed.user if uri_parsed.user
			options[:password] = uri_parsed.password if uri_parsed.password

			JSON.parse(RestClient::Request.execute(options))
		end

		def copy(uri, destination)
			options = {
				:method => :copy,
				:url => uri,
				:headers => default_headers.merge('Destination' => destination)
			}

			uri_parsed = URI(uri)
			options[:user] = uri_parsed.user if uri_parsed.user
			options[:password] = uri_parsed.password if uri_parsed.password

			JSON.parse(RestClient::Request.execute(options).to_s)
		end
	end

	CouchRest.extend(::CouchRest::RestAPI)
end

# Adds functions to Numeric to convert a number to radians/degrees
class Numeric
	# Turns the number that is in degrees to radians.
	def to_radians
		self * Math::PI / 180.0
	end

	# Turns the number that is in radians to degrees.
	def to_degrees
		self * 180.0 / Math::PI
	end
end
