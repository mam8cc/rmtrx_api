require 'mongoid'

class ApiAuthenticator
	def createKey  do
		@key = SecureRandom.uuid;

		Kyes.create(
			key: @key
		)

		return @key
	end
end

class Keys
	include Mongoid::Document
	field :key, type: String
end	