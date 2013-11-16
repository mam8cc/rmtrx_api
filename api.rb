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

	return User.where(id: @id).first.to_json
end

post '/account' do
	@email = params[:email]
	@firstName = params[:first_name]
	@lastName = params[:last_name]
	@password = params[:password]
	@residenceName = params[:residence_name]

	existingUser = User.where(email: @email).first

	if existingUser != nil
		error 406
	else
		residence = Residence.create(
			name: @residenceName,
			updateTime: DateTime.now
		)

		chatLog = ChatLog.create(
			residenceId: residence._id
		)

		user = residence.users.create(
			email: @email,
			firstName: @firstName,
			lastName: @lastName
		)

		Password.create(
			userId: user._id,
			password: @password
		)

		return {"user" => user, "residence" => residence, "key" => auth.createKey()}.to_json
	end
end

post '/residence' do
	@name = params[:name]
	@userId = params[:user_id]

	user = User.where(_id: @userId).first

	users = Array.new
	users.push(user)

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
	@email = params[:email]
	@firstName = params[:first_name]
	@lastName = params[:last_name]
	@password = params[:password]

	code = ResidenceCode.where(code: @code).first

	if code == nil
		error 404
	else
		residence = Residence.where(_id: code.residenceId).first

		user = residence.users.create(
				email: @email,
				firstName: @firstName,
				lastName: @lastName
			)

		Password.create(
				userId: user._id,
				password: @password
			)

		return {'user' => user, "residence" => residence, "key" => auth.createKey()}.to_json
	end
end

post '/authenticate' do
	@email = params[:email]
	@password = params[:password]

	residence = Residence.where('users.email' => @email).first

	if residence == nil
		error 404
	else	
		user = residence.users.where(email: @email).first

		if user == nil
			error 404
		else
			return {"user" => user, "residence" => residence, "key" => auth.createKey()}.to_json
		end
	end
end

post '/list' do
	@residenceId = params[:residence_id]
	@listName = params[:list_name]

	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.create(
		listName: @listName
	)

	return list.to_json
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

	return list.to_json
end

put '/list/item' do
	@residenceId = params[:residence_id]
	@listId = params[:list_id]
	@itemId = params[:item_id]
	@itemStatus = params[:item_status]
	
	residence = Residence.where(_id: @residenceId).first
	residence.to_json
	list = residence.groceryLists.where(_id: @listId).first
	item = list.groceryListItems.where(_id: @itemId).first

	if item != nil
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

