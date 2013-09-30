require 'sinatra'
require 'mongoid'
require 'json'

Mongoid.load!("mongoid.yml")

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

auth = ApiAuthenticator.new

#Allows for testing from a Chrome Extension HTTP
set :protection, :origin_whitelist => ['chrome-extension://hgmloofddffdnphfgcellkdfbfbjeloo']

post '/user' do
	@username = params[:username]
	@password = params[:password]

	User.create(
		username: @username,
		password: @password
	)

	auth.createKey()
end

post '/authenticate' do

	params.inspect

	# @username = params[:username]
	# @password = params[:password]

	# user = User.where(username: @username).first

	# if user.password == @password
	# 	key = auth.createKey()
	# 	payload = [key]
	# 	return payload.to_json
	# else
	# 	"Whomp whomp."
	# end
end

get '/validkey' do
	if auth.isKeyValid
		'Valid'
	else
		'Invalid'
	end
end

class Key
	include Mongoid::Document
	field :key, type: String
end	

class User 
	include Mongoid::Document
	field :username, type: String
	field :password, type: String
end