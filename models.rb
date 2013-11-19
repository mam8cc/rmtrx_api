class User 
	include Mongoid::Document

	field :email, type: String
	field :firstName, type: String
	field :lastName, type: String

	embedded_in :residence
end

class Password
	include Mongoid::Document

	field :userId, type: String
	field :password, type: String
end

class ResidenceCode
	include Mongoid::Document

	field :code, type: String
	field :residenceId, type: String
end

class Residence
	include Mongoid::Document

	field :name, type: String
	field :updateTime, type: DateTime

	field :groceryListLastUpdate, type: Integer

	embeds_many :groceryLists
	embeds_many :events
	embeds_many :messages
	embeds_many :users
	embeds_many :ledgers
end

class GroceryList
	include Mongoid::Document

	field :listName, type: String

	embeds_many :groceryListItems

	embedded_in :residence
end

class GroceryListItem
	include Mongoid::Document

	field :itemName, type: String
	field :itemStatus, type: Boolean

	embedded_in :groceryList
end

class Event
	include Mongoid::Document

	field :eventName, type: String
	field :eventLocation, type: String
	field :eventDetails, type: String
	field :eventDate, type: DateTime

	embedded_in :residence
end

class Key
	include Mongoid::Document
	field :key, type: String
end	

class ChatLog
	include Mongoid::Document

	field :residenceId, type: String

	embeds_many :messages
end

class Message
	include Mongoid::Document
	field :message, type: String
	field :senderId, type: String
	field :dateSent, type: DateTime

	embedded_in :chat
end

class Ledger
	include Mongoid::Document

	field :payer, type: String
	field :payee, type: String
	field :amount, type: Integer
	field :note, type: String
	field :transactionDate, type: DateTime

	embedded_in :residence
end