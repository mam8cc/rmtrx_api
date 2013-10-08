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

before do
    content_type 'application/json'

   #  if auth.isKeyValid(params[:key])
		 # return Key.where(key: key).exists?
   #  else
   #  	error 401
   #  end
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
		key = auth.createKey()
		return key.to_json
	else
		"Whomp whomp."
	end
end

get '/validkey/:key' do
	if auth.isKeyValid(params[:key])
		'Valid'
	else
		'Invalid'
	end
end

get '/create' do
	residence = Residence.create(
		
	)
end

get '/api' do

end

class Key
	include Mongoid::Document

	field :key, type: String
end	

class User 
	include Mongoid::Document

	field :userId, type: Integer
	field :username, type: String
	field :password, type: String
	field :firstName, type: String
	field :lastName, type: String
	field :email, type: String

	embedded_in :residence
end

class Residence
	include Mongoid::Document

	field :residenceId, type: Integer
	field :name, type: String
	field :address, type: String

	embeds_many :users
	embeds_many :groceryLists
	embeds_many :events
end

class GroceryList
	include Mongoid::Document

	field :itemName, type: String
	field :itemDescription, type: String

	embedded_in :residence
end

class Event
	include Mongoid::Document

	field :eventName, type: String
	field :eventLocation, type: String
	field :eventDetails, type: String
	field :eventDate, type: DateTime

	embedded_in :residence
end

