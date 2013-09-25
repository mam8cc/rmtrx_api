require 'sinatra'
require 'mongoid'

get '/' do
  "Hello, world"
end

post '/user/' do
	@username = params[:username]
	@password = params[:password]

	puts @username
	puts @password
end
