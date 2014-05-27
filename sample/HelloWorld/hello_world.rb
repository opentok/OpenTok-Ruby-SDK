require 'sinatra/base'
require 'opentok'

raise "You must define API_KEY and API_SECRET environment variables" unless ENV.has_key?("API_KEY") && ENV.has_key?("API_SECRET")

class HelloWorld < Sinatra::Base

  set :api_key, ENV['API_KEY']
  set :opentok, OpenTok::OpenTok.new(api_key, ENV['API_SECRET'])
  set :session, opentok.create_session

  get '/' do

    api_key = settings.api_key
    session_id = settings.session.session_id
    token = settings.opentok.generate_token(session_id)

    erb :index, :locals => {
      :api_key => api_key,
      :session_id => session_id,
      :token => token
    }
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
