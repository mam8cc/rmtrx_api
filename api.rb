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

	puts request.body              # request body sent by the client (see below)
    puts request.scheme            # "http"
    puts request.script_name       # "/example"
    puts request.path_info         # "/foo"
    puts request.port              # 80
    puts request.request_method    # "GET"
    puts request.query_string      # ""
    puts request.content_length    # length of request.body
    puts request.media_type        # media type of request.body
    puts request.host              # "example.com"
    puts request.get?              # true (similar methods for other verbs)
    puts request.form_data?        # false
    puts request["SOME_HEADER"]    # value of SOME_HEADER header
    puts request.referer           # the referer of the client or '/'
    puts request.user_agent        # user agent (used by :agent condition)
    puts request.cookies           # hash of browser cookies
    puts request.xhr?              # is this an ajax request?
    puts request.url               # "http://example.com/example/foo"
    puts request.path              # "/example/foo"
    puts request.ip                # client IP address
    puts request.secure?           # false
    puts request.env 

	@username = params[:username]
	@password = params[:password]

	user = User.where(username: @username).first

	if user.password == @password
		key = auth.createKey()
		payload = [key]
		return payload.to_json
	else
		"Whomp whomp."
	end
end

get '/validkey' do
	if auth.isKeyValid
		'Valid'
	else
		'Invalid'
	end
end

class Key
	include Mongoid::Document
	field :key, type: String
end	

class User 
	include Mongoid::Document
	field :username, type: String
	field :password, type: String
end