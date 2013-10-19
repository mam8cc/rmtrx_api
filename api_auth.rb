class ApiAuthenticator
	def createKey
		@key = SecureRandom.uuid;

		keyObject = Key.create(
			key: @key
		)

		return keyObject
	end

	def isKeyValid(key)
		 return Key.where(key: key).exists?
	end
end

