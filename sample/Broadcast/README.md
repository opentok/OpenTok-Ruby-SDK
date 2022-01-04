# OpenTok Broadcasting Sample for Ruby

This is a simple demo app that shows how you can use the OpenTok Ruby SDK to broadcast 
sessions and how to stop them, change the layout of the broadcast and/or the streams within.

## Running the App

First, download the dependencies using [Bundler](http://bundler.io)

```
$ bundle install
```

Next, add your OpenTok API key and API secret to the environment variables. There are a few ways to do
this but the simplest would be to do it right in your shell.

```
$ export API_KEY=0000000
$ export API_SECRET=abcdef1234567890abcdef01234567890abcdef
```

Finally, start the server using Bundler to handle dependencies

```
$ bundle exec ruby broadcast_sample.rb
```

Visit <http://localhost:4567> in your browser. You can now create new broadcast (with a host and
as a participant) and also view those broadcasts.

## Walkthrough

This demo application uses the same frameworks and libraries as the HelloWorld sample. If you have
not already gotten familiar with the code in that project, consider doing so before continuing.

The explanations below are separated by page. Each section will focus on a route handler within the
main application (broadcast_sample.rb).

### Creating Broadcasts – Host View

The Host view manages the broadcasting process. Visit the host page at <http://localhost:4567/host>.
Your browser will first ask you to approve permission to use the camera and microphone.
Once you've accepted, your image will appear inside the section titled 'Host'. To start broadcasting
the video stream, press the 'Start Broadcast' button. You can specify the maximum duration,
resolution, and layout of the broadcast. Once broadcasting has begun the button will turn
green and change to 'Stop Broadcast'. Click this button when you are done broadcasting.

The host page basically sets up the OpenTok session with the API key and secret you provided.
If a previously started broadcast exists, it defaults to it, along with the layout and the stream
that has the focus:

```ruby
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
```

This handler generates the three strings that the client (JavaScript) needs to connect
to the session: `apiKey`, `sessionId`, and `token`. The `initialBroadcastId` is the broadcast ID,
`focusStreamId` is the stream ID that has the current focus (if there is one), and
`initialLayout` is the initial layout for the current broadcast in progress (if there is one).
(We will discuss focus stream and broadcast layout below.)

In the host page, the user presses the 'Start Broadcast' button, which sends an XHR (or Ajax)
request to the <http://localhost:4567/start> URL. The route handler for this URL is shown below:

```ruby
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
```

In this handler, `opentok.broadcasts.create` is called with the `session_id` for
the OpenTok session to broadcast. The optional second argument is a hash which defines
optional properties for the broadcast. It consists of `maxDuration` of the broadcast,
`resolution`, and broadcast `layout`. This sample app starts an HLS broadcast (not RTMP),
so it only specifies an `hls` property of the `outputs` property. See the
[Ruby SDK documentation](https://github.com/opentok/OpenTok-Ruby-SDK) for information
on adding RTMP broadcast streams. In this case, as in the HelloWorld sample app, there is
only one session created and it is used here and for the participant view.
This will trigger the broadcasting to begin. The response sent back to the client’s XHR request
will be the JSON representation of the broadcast, which is returned from the `to_json()` method. 

You can view the HLS broadcast by opening the root URL (<http://localhost:4567/>) in
a different tab and clicking the `Broadcast URL` button. The code for handling this is as follows:

```ruby
  get '/broadcast' do
    return 'No broadcast id exists' if settings.broadcast_id.nil? || settings.broadcast_id.empty?
    broadcast = settings.opentok.broadcasts.find settings.broadcast_id
    redirect broadcast.broadcastUrls['hls'] if broadcast.status == 'started'
 end
```

The route for Stop Broadcast has the following code:

```ruby
  get '/stop/:broadcastId' do
    broadcast = settings.opentok.broadcasts.stop settings.broadcast_id
    settings.broadcast_id = nil
    settings.focus_stream_id = ''
    settings.broadcast_layout = 'horizontalPresentation'
    body broadcast.to_json
  end
```

The settings revert backs to the settings when you start the app.

The host page includes a `Toggle Layout` button, which toggles between
`verticalPresentation` and `horizontalPresentation`.

The route for `Toggle Layout` has the following code:

```ruby
   post '/broadcast/:broadcastId/layout' do
     layoutType = params[:type]
     settings.opentok.broadcasts.layout(settings.broadcast_id, type: layoutType)
     settings.broadcast_layout = layoutType
   end
```

This calls the `opentok.broadcasts.layout()` method, setting the broadcast layout to
the layout type defined in the POST request's body. In this app, the layout type is
set to `horizontalPresentation` or `verticalPresentation`, two of the [predefined layout
types](https://tokbox.com/developer/guides/broadcast/live-streaming/#predefined-layout-types)
available to live streaming broadcasts.

### Creating Broadcast - Participant View

With the host view still open and publishing, open an additional tab and navigate to
<http://localhost:4567/participant> and allow the browser to use your camera and microphone.
You will now see the participant in the broadcast.

```ruby
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
```

### Changing the layout classes for streams

In the host page, if you click on either the host or a participant video, that video gets
the `focus` layout in the broadcast. The host page sends the `focus` stream ID and
the other streams' layout class lists can be cleared, as shown below:

```ruby
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
```

The host client page also uses OpenTok signaling to notify other clients when the layout type and
focus stream changes, and they then update the local display of streams in the HTML DOM accordingly.
However, this is not necessary. The layout of the broadcast is unrelated to the layout of
streams in the web clients.

When you view the broadcast stream, the layout type and focus stream changes, based on calls
to the `OpenTok.setBroadcastLayout()` and `OpenTok.setStreamClassLists()` methods during
the broadcast.

For more information, see [Configuring video layout for OpenTok live streaming
broadcasts](https://tokbox.com/developer/guides/broadcast/live-streaming/#configuring-video-layout-for-opentok-live-streaming-broadcasts).
