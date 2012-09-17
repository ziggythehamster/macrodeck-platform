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

	module RestAPI
		# Perform the RestClient request by removing the parse specific options, ensuring the 
		# payload is prepared, and sending the request ready to parse the response.
		#
		# The monkeypatch here is to parse the URI and get username and password if they're provided.
		def execute(url, method, options = {}, payload = nil)
			request, parser = prepare_and_split_options(url, method, options)

			# Prepare the payload if it is provided
			request[:payload] = payload_from_doc(payload, parser) if payload

			uri = URI(url)

			if uri.user && uri.password
				request[:user] = uri.user
				request[:password] = uri.password
			end

			begin
				parse_response(RestClient::Request.execute(request), parser)
			rescue Exception => e
				if $DEBUG
					raise "Error while sending a #{method.to_s.upcase} request #{uri}\noptions: #{opts.inspect}\n#{e}"
				else
					raise e
				end
			end
		end
	end
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
