require 'sinatra'
require 'mongoid'

Mongoid.load!("mongoid.yml")

#Allows for testing from a Chrome Extension HTTP
set :protection, :origin_whitelist => ['chrome-extension://hgmloofddffdnphfgcellkdfbfbjeloo']

get '/' do
  "Hello, world"
end

post '/user/' do
	@username = params[:username]
	@password = params[:password]

	Users.create(
		username: @username,
		password: @password
	)

	"#{@username}, #{@password}"
end

class User 
	include Mongoid::Document
	field :username, type: String
	field :password, type: String
end