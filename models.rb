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
	field :updateTime, type: DateTime

	embeds_many :groceryLists
	embeds_many :events
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