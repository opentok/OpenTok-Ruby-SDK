require 'sinatra/base'
require 'opentok'

raise "You must define API_KEY and API_SECRET environment variables" unless ENV.has_key?("API_KEY") && ENV.has_key?("API_SECRET")

class BroadcastSample < Sinatra::Base

  set :api_key, ENV['API_KEY']
  set :opentok, OpenTok::OpenTok.new(api_key, ENV['API_SECRET'])
  set :session, opentok.create_session(:media_mode => :routed)
  set :erb, :layout => :layout
  set :broadcastId, nil
  set :focusStreamId, ''
  set :broadcastLayout, 'bestFit'

  get '/' do
    erb :index
  end

  get '/host' do
    api_key = settings.api_key
    session_id = settings.session.session_id
    token = settings.opentok.generate_token(session_id, role: :publisher, initialLayoutClassList: ['focus'])

    erb :host, locals: {
        apiKey: api_key,
        sessionId: session_id,
        token: token,
        initialBroadcastId: settings.broadcastId,
        focusStreamId: settings.focusStreamId,
        initialLayout: settings.broadcastLayout
    }
  end

  get '/participant' do
    api_key = settings.api_key
    session_id = settings.session.session_id
    token = settings.opentok.generate_token(session_id, role: :publisher)

    erb :participant, locals: {
        apiKey: api_key,
        sessionId: session_id,
        token: token,
        focusStreamId: settings.focusStreamId,
        layout: settings.broadcastLayout
    }
  end

  post '/start' do
    puts params
    opts = {
        :maxDuration => params.key?("maxDuration") ? params[:maxDuration] : 7200,
        :resolution =>  params[:resolution],
        :layout => params[:layout],
        :outputs => {
            :hls => {}
        }
    }
    b = settings.opentok.broadcasts.create(settings.session.session_id, opts)
    settings.broadcastId = b.id
    puts b.to_json
    body b.to_json
  end

  get '/broadcast' do
    b = settings.opentok.broadcasts.find settings.broadcastId
    redirect b.broadcastUrls['hls'] if b.status == 'started'
  end

  get '/stop/:broadcastId' do
    settings.opentok.broadcasts.stop settings.broadcastId
    settings.broadcastId = nil
  end

  post '/broadcast/:broadcastId/layout' do
    layoutType = params[:type]
    settings.opentok.broadcasts.layout(settings.broadcastId, type: layoutType)
    settings.broadcastLayout = layoutType
  end

  post '/focus' do
    puts params
    hash = { items: [] }
    hash[:items] << { id: params[:focus], layoutClassList: ['focus', 'full'] }
    settings.focusStreamId = params[:focus]
    if params.key?('otherStreams')
      params[:otherStreams].each do |stream|
        hash[:items] << { id: stream, layoutClassList: [] }
      end
    end
    puts hash
    settings.opentok.streams.layout(settings.session.session_id, hash)
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
