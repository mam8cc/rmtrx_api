require 'sinatra'
require 'mongoid'
require 'json'
require "./models.rb"
require "./api_auth.rb"

Mongoid.load!("mongoid.yml")

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

get '/user/:id' do
	@id = params[:id]

	return rUser.where(id: @id).first.to_json
end

post '/user' do
	@email = params[:email]
	@firstName = params[:first_name]
	@lastName = params[:last_name]
	@password = params[:password]

	existingUser = User.where(email: @email).first

	if existingUser != nil
		error 406
	else
		user = User.create(
			email: @email,
			password: @password,
			firstName: @firstName,
			lastName: @lastName
		)

		return {"user" => user, "key" => auth.createKey()}.to_json
	end
end

post '/residence' do
	@name = params[:name]
	@userId = params[:user_id]

	users = Array.new
	users.push(@userId)

	puts users.inspect

	residence = Residence.create(
		name: @name,
		users: users
	)

	return residence.to_json
end

get '/residence/:id' do
	@residenceId = params[:id]

	residence = Residence.where(_id: @residenceId).first

	if residence == nil
		error 404
	else
		return residence.to_json
	end
end

#this is gross, but its get residence by userId
get '/residence/user/:id' do
	@userId = params[:id]
	
end

post '/code' do
	@residenceId = params[:residence_id]
	@code = params[:code]

	code = ResidenceCode.create(
		code: @code,
		residenceId: @residenceId
	)

	return code.to_json
end

post '/join' do
	@code = params[:code]
	@userId = params[:user_id]

	code = ResidenceCode.where(code: @code).first
	residence = Residence.where(_id: code.residenceId).first

	residence.users.push(@userId)

	return residence.to_json
end

post '/authenticate' do
	@email = params[:email]
	@password = params[:password]

	user = User.where(email: @email).first

	if user != nil 
		if user.password == @password
			key = auth.createKey()
			return {"user" => user, "key" => auth.createKey()}.to_json
		else
			error 401
		end
	else
		error 401
	end
end

post '/list' do
	@residenceId = params[:residence_id]
	@listName = params[:list_name]

	residence = Residence.where(_id: @residenceId).first
	residence.groceryLists.create(
		listName: @listName
	)

	return residence.to_json
end

post '/list/item' do
	@residenceId = params[:residence_id]
	@listId = params[:list_id]
	@itemName = params[:item_name]

	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.where(_id: @listId).first

	list.groceryListItems.create(
		itemName: @itemName,
		itemStatus: false
	)

	return residence.to_json
end

put 'list/item' do
	@residenceId = params[:residence_id]
	@listId = params[:list_id]
	@itemId = params[:item_id]

	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.where(_id: @listId).first
	listItem = list.GroceryListItems.where(_id: @itemId)

	
end

