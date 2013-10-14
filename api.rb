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
	@email = params[:email]
	@firstName = params[:first_name]
	@lastName = params[:last_name]
	@password = params[:password]

	user = User.create(
		email: @email,
		password: @password,
		firstName: @firstName,
		lastName: @lastName
	)

	return {"user" => user, "key" => auth.createKey()}.to_json
end

post '/residence' do
	@name = params[:name]
	@userId = params[:userId]

	users = Array.new
	users.push(@userId)

	puts users.inspect

	residence = Residence.create(
		name: @name,
		users: users
	)

	return {"residence" => residence}.to_json
end

get '/residence/:id' do
	@residenceId = params[:id]

	residence = Residence.where(_id: @residenceId).first

	if residence == nil
		error 404
	else
		return {"residence" => residence}.to_json
	end
end

post '/code' do
	@residenceId = params[:residence_id]
	@code = params[:code]

	code = ResidenceCode.create(
		code: @code,
		residenceId: @residenceId
	)

	return {"code" => code}.to_json
end

post '/join' do
	@code = params[:code]
	@userId = params[:user_id]

	code = ResidenceCode.where(code: @code).first
	residence = Residence.where(_id: code.residenceId).first

	residence.users.push(@userId)

	return {"residence" => residence}.to_json
end

post '/authenticate' do
	@email = params[:email]
	@password = params[:password]

	user = User.where(email: @email).first

	if user != nil 
		if user.password == @password
			key = auth.createKey()
			return key.to_json
		else
			error 401
		end
	else
		error 401
	end
end

get '/api' do
	
end

class Key
	include Mongoid::Document

	field :key, type: String
end	

class User 
	include Mongoid::Document

	field :email, type: String
	field :password, type: String
	field :firstName, type: String
	field :lastName, type: String
end

class ResidenceCode
	include Mongoid::Document

	field :code, type: String
	field :residenceId, type: String
end

class Residence
	include Mongoid::Document

	field :name, type: String
	field :users, type: Array

	embeds_many :groceryLists
	embeds_many :events
end

class Member
	include Mongoid::Document

	field :userId, type: Integer

	embedded_in :residence
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

