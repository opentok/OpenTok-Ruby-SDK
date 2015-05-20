require 'sinatra/base'
require 'opentok'

raise "You must define API_KEY and API_SECRET environment variables" unless ENV.has_key?("API_KEY") && ENV.has_key?("API_SECRET")

class ArchivingSample < Sinatra::Base

  set :api_key, ENV['API_KEY']
  set :opentok, OpenTok::OpenTok.new(api_key, ENV['API_SECRET'])
  set :session, opentok.create_session(:media_mode => :routed)
  set :erb, :layout => :layout

  get '/' do
    erb :index
  end

  get '/host' do
    api_key = settings.api_key
    session_id = settings.session.session_id
    token = settings.opentok.generate_token(session_id, :role => :moderator)

    erb :host, :locals => {
      :api_key => api_key,
      :session_id => session_id,
      :token => token
    }
  end

  get '/participant' do
    api_key = settings.api_key
    session_id = settings.session.session_id
    token = settings.opentok.generate_token(session_id, :role => :moderator)

    erb :participant, :locals => {
      :api_key => api_key,
      :session_id => session_id,
      :token => token
    }
  end

  get '/history' do
    page = (params[:page] || "1").to_i
    offset = (page - 1) * 5
    archives = settings.opentok.archives.all(:offset => offset, :count => 5)

    show_previous = page > 1 ? '/history?page=' + (page-1).to_s : nil
    show_next = archives.total > (offset + 5) ? '/history?page=' + (page+1).to_s : nil

    erb :history, :locals => {
      :archives => archives,
      :show_previous => show_previous,
      :show_next => show_next
    }
  end

  get '/download/:archive_id' do
    archive = settings.opentok.archives.find(params[:archive_id])
    redirect archive.url
  end

  post '/start' do
    archive = settings.opentok.archives.create settings.session.session_id, {
      :name => "Ruby Archiving Sample App",
      :output_mode => params[:output_mode],
      :has_audio => params[:has_audio] == "on",
      :has_video => params[:has_video] == "on"
    }
    body archive.to_json
  end

  get '/stop/:archive_id' do
    archive = settings.opentok.archives.stop_by_id(params[:archive_id])
    body archive.to_json
  end

  get '/delete/:archive_id' do
    settings.opentok.archives.delete_by_id(params[:archive_id])
    redirect '/history'
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
