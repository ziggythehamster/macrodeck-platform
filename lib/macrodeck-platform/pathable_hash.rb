module MacroDeck
	# Works the same as Hash, except can be converted
	# to paths.
	class PathableHash < Hash
		def each_path
			raise ArgumentError unless block_given?
			self.class.each_path(self) do |path, object|
				yield path, object
			end
		end

		protected
			def self.each_path(object, path = '', &block)
				if object.is_a?(Hash)
					object.each do |key, value|
						self.each_path value, "#{path}#{key}/", &block
					end
				else
					yield path, object
				end
			end
	end
end
