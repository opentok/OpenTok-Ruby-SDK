require 'sinatra/base'
require 'opentok'

raise "You must define API_KEY and API_SECRET environment variables" unless ENV.has_key?("API_KEY") && ENV.has_key?("API_SECRET")

class BroadcastSample < Sinatra::Base

  set :api_key, ENV['API_KEY']
  set :opentok, OpenTok::OpenTok.new(api_key, ENV['API_SECRET'])
  set :session, opentok.create_session(:media_mode => :routed)
  set :erb, :layout => :layout
  set :broadcast_id, nil
  set :focus_stream_id, ''
  set :broadcast_layout, 'horizontalPresentation'

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
        initialBroadcastId: settings.broadcast_id,
        focusStreamId: settings.focus_stream_id,
        initialLayout: settings.broadcast_layout
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
        focusStreamId: settings.focus_stream_id,
        layout: settings.broadcast_layout
    }
  end

  post '/start' do
    opts = {
        :maxDuration => params.key?("maxDuration") ? params[:maxDuration] : 7200,
        :resolution =>  params[:resolution],
        :layout => params[:layout],
        :outputs => {
            :hls => {}
        }
    }
    broadcast = settings.opentok.broadcasts.create(settings.session.session_id, opts)
    settings.broadcast_id = broadcast.id
    body broadcast.to_json
  end

  get '/broadcast' do
    return 'No broadcast id exists' if settings.broadcast_id.nil? || settings.broadcast_id.empty?
    broadcast = settings.opentok.broadcasts.find settings.broadcast_id
    redirect broadcast.broadcastUrls['hls'] if broadcast.status == 'started'
  end

  get '/stop/:broadcastId' do
    broadcast = settings.opentok.broadcasts.stop settings.broadcast_id
    settings.broadcast_id = nil
    settings.focus_stream_id = ''
    settings.broadcast_layout = 'horizontalPresentation'
    body broadcast.to_json
  end

  post '/broadcast/:broadcastId/layout' do
    layoutType = params[:type]
    settings.opentok.broadcasts.layout(settings.broadcast_id, type: layoutType)
    settings.broadcast_layout = layoutType
  end

  post '/focus' do
    hash = { items: [] }
    hash[:items] << { id: params[:focus], layoutClassList: ['focus'] }
    settings.focus_stream_id = params[:focus]
    if params.key?('otherStreams')
      params[:otherStreams].each do |stream|
        hash[:items] << { id: stream, layoutClassList: [] }
      end
    end
    settings.opentok.streams.layout(settings.session.session_id, hash)
  end

  # start the server if ruby file executed directly
  run! if app_file == $0
end
