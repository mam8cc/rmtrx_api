require 'sinatra'
require 'mongoid'

Mongoid.load!("mongoid.yml")

class ApiAuthenticator
	def createKey
		@key = SecureRandom.uuid;

		Key.create(
			key: @key
		)

		return @key
	end
end


auth = ApiAuthenticator.new

#Allows for testing from a Chrome Extension HTTP
set :protection, :origin_whitelist => ['chrome-extension://hgmloofddffdnphfgcellkdfbfbjeloo']

get '/' do
  	@username = 'test'
	@password = 'test'

	User.create(
		username: @username,
		password: @password
	)
end

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
	@username = params[:username]
	@password = params[:password]

	user = User.where(username: @username).first

	if user.password == @password
		auth.createKey()
	else
		"Whomp whomp."
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