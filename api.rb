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

	residence = Residence.create(
		name: @name,
		users: users,
		updateTime: DateTime.now
	)

	chatLog = ChatLog.create(
		residenceId: residence._id
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

get '/user/:id' do
	@userId = params[:user_id]

	user = User.where(_id: @userId).first

	if user == nil
		error 404
	else
		user.to_json
	end
end

#this is gross, but its get residence by userId
get '/residence/user/:id' do
	@userId = params[:id]

	residence = Residence.any_in(users: @userId)

	if(residence[0] != nil)
		return residence[0].to_json
	else
		return 404
	end
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
	@residenceId = params[:residence_id]
	@listId = params[:list_id]
	@itemId = params[:list_item_id]
	@itemName = params[:list_item_name]
	@itemStatus = params[:list_item_status]
	
	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.where(_id: @listId).first
	item = list.groceryListItems.where(_id: @itemId).first

	if item != nil
		#TODO: 
		item.Name = @itemName
		item.itemStatus = @itemStatus

		return residence.to_json
	else
		return 404
	end
end

post '/message' do
	@residenceId = params[:residence_id]
	@userId = params[:user_id]
	@message = params[:message]

	chatLog = ChatLog.where(residenceId: @residenceId).first
	message = chatLog.messages.create(
		senderId: @userId,
		message: @message,
		dateSent: DateTime.now
	)

	return message.to_json
end

get '/residence/:id/chatlog' do
	@residenceId = params[:id]

	chatLog = ChatLog.where(residenceId: @residenceId).first 

	messages = chatLog.messages
	return messages.to_json
	# length = messages.length
	# bound = length - 25

	# limitedMessages = messages.reject{|i| i < bound}return {"messages.to_json" => messages, "chatLog" => chatLog}.to_json
	# if chatLog != nil
	# 	return chatLog.to_json
	# else
	# 	error 404
	# end
end

