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

	request.body              # request body sent by the client (see below)
    request.scheme            # "http"
    request.script_name       # "/example"
    request.path_info         # "/foo"
    request.port              # 80
    request.request_method    # "GET"
    request.query_string      # ""
    request.content_length    # length of request.body
    request.media_type        # media type of request.body
    request.host              # "example.com"
    request.get?              # true (similar methods for other verbs)
    request.form_data?        # false
    request["SOME_HEADER"]    # value of SOME_HEADER header
    request.referer           # the referer of the client or '/'
    request.user_agent        # user agent (used by :agent condition)
    request.cookies           # hash of browser cookies
    request.xhr?              # is this an ajax request?
    request.url               # "http://example.com/example/foo"
    request.path              # "/example/foo"
    request.ip                # client IP address
    request.secure?           # false
    request.env 

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