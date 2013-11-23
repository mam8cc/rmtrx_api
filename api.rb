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

		residence.groceryListLastUpdate = DateTime.now.to_time.to_i
		residence.ledgerLastUpdate = DateTime.now.to_time.to_i

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

		residence.save!
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

	residence.groceryListLastUpdate = DateTime.now.to_time.to_i
	residence.save!

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

get '/residence/:residence_id/list/update_time' do
	@residenceId = params[:residence_id]

	residence = Residence.where(_id: @residenceId).first

	return {"time_stamp" => residence.groceryListLastUpdate.to_s}.to_json
end

get '/residence/:residence_id/list' do
	@residenceId = params[:residence_id]

	residence = Residence.where(_id: @residenceId).first

	lists = residence.groceryLists

	return lists.to_json
end

post '/list' do
	@residenceId = params[:residence_id]
	@listName = params[:list_name]

	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.create(
		listName: @listName
	)

	residence.groceryListLastUpdate = DateTime.now.to_time.to_i
	residence.save!

	return list.to_json
end

delete '/residence/:residence_id/list/:list_id' do
	@residenceId = params[:residence_id]
	@listId = params[:list_id]
	
	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.where(_id: @listId).first

	list.delete

	residence.groceryListLastUpdate = DateTime.now
	residence.save!
end

post '/list/item' do
	@residenceId = params[:residence_id]
	@listId = params[:list_id]
	@itemName = params[:item_name]

	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.where(_id: @listId).first

	item = list.groceryListItems.create(
		itemName: @itemName,
		itemStatus: false
	)

	residence.groceryListLastUpdate = DateTime.now.to_time.to_i
	residence.save!

	return item.to_json
end

put '/list/item' do
	@residenceId = params[:residence_id]
	@listId = params[:list_id]
	@itemId = params[:item_id]
	@itemStatus = params[:item_status]
	
	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.where(_id: @listId).first
	item = list.groceryListItems.where(_id: @itemId).first

	if item != nil
		item.itemStatus = @itemStatus
		item.save!

		residence.groceryListLastUpdate = DateTime.now.to_time.to_i
		residence.save!

		return item.to_json
	else
		return 404
	end
end

delete '/residence/:residence_id/list/:list_id/item/:item_id' do
	@residenceId = params[:residence_id]
	@listId = params[:list_id]
	@itemId = params[:item_id]

	residence = Residence.where(_id: @residenceId).first
	list = residence.groceryLists.where(_id: @listId).first
	item = list.groceryListItems.where(_id: @itemId).first

	item.delete
	residence.groceryListLastUpdate = DateTime.now.to_time.to_i
	residence.save!
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

	# messages = chatLog.messages.to_a
	# length = messages.length
	# bound = length - 25

	# limitedMessages = messages.reject{|i| i < bound}
	if chatLog != nil
		return chatLog.to_json
	else
		error 404
	end
end

get '/residence/:residence_id/ledger' do
	@residenceId = params[:residence_id]

	residence = Residence.where(_id: @residenceId).first

	if residence != nil
		return {"ledgers" => residence.transactions}.to_json
	else
		error 404
	end
end

get '/residence/:residence_id/ledger/last_update' do
	@residenceId = params[:residence_id]

	residence = Residence.where(_id: @residenceId).first

	if residence != nil
		return {"time_stamp" => residence.ledgerLastUpdate}.to_json
	else
		error 404
	end
end

post '/transaction' do
	@residenceId = params[:residence_id]
	@payer = params[:from_user]
	@payee = params[:to_user]
	@note = params[:note]
	@amount = params[:amount]

	residence = Residence.where(_id: @residenceId).first
	
	if residence != nil
		transaction = residence.Transaction.create(
			payer: @payer,
			payee: @payee,
			note: @note,
			amount: @amount,
			transactionDate: DateTime.now.to_time.to_i 
		)

		residence.ledgerLastUpdate = DateTime.now.to_time.to_i

		return transaction.to_json
	else
		error 404
	end
end
