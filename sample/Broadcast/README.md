# OpenTok Broadcasting Sample for Ruby

This is a simple demo app that shows how you can use the OpenTok Java SDK to broadcast 
sessions and how to stop them, change the layout of the broadcast and/or the streams within.

## Running the App

First, download the dependencies using [Bundler](http://bundler.io)

```
$ bundle install
```

Next, add your own API Key and API Secret to the environment variables. There are a few ways to do
this but the simplest would be to do it right in your shell.

```
$ export API_KEY=0000000
$ export API_SECRET=abcdef1234567890abcdef01234567890abcdef
```

Finally, start the server using Bundler to handle dependencies

```
$ bundle exec ruby broadcast_sample.rb
```

Visit <http://localhost:4567> in your browser. You can now create new broadcast (with  a host and
as a participant) and also view those broadcasts.

## Walkthrough

This demo application uses the same frameworks and libraries as the HelloWorld sample. If you have
not already gotten familiar with the code in that project, consider doing so before continuing.

The explanations below are separated by page. Each section will focus on a route handler within the
main application (broadcast_sample.rb).

### Creating Broadcasts – Host View

The Host view manages the broadcasting process. The participants (view) just join and exit the broadcast 
sessions independently.
Start by visiting the host page at <http://localhost:4567/host> and using the application to start
a broadcast. Your browser will first ask you to approve permission to use the camera and microphone.
Once you've accepted, your image will appear inside the section titled 'Host'. To start broadcasting
the video stream, press the 'Start Broadcast' button. You can specify the maximum duration , resolution and layout
of the broadcast. Once broadcasting has begun the button will turn
green and change to 'Stop Broadcast'.  Stop broadcasting when you are done. 

The host page , basically sets up the opentok session with the api key and secret you provided. If a previously started 
 broadcast exists , it defaults to it , along with the layout and the stream which had the 'full' focus.

```ruby
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

```

This handler simply
generates the three strings that the client (JavaScript) needs to connect to the session: `api_key`,
`session_id` and `token`. The `initialBroadcastId` is the broadcast id , `focusStreamId` is the stream id which has the current
focus and `initialLayout` is the initial layout for the current broadcast which is being started. After the user 
has connected to the session, they press the
'Start Broadcast' button, which sends an XHR (or Ajax) request to the <http://localhost:4567/start>
URL. The route handler for this URL is shown below:

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
    settings.broadcastId = broadcast.id
    body broadcast.to_json
  end
```

In this handler, `opentok.broadcasts.create` is called with the `session_id` for the broadcasting session
The optional second argument is a hash which defines optional properties
for the broadcast. It consists of `maxDuration` of the broadcast, `resolution` and broadcast `layout`.
In this sample app we only care for `hls` broadcasting hence we only specify that. 
You can add RTMP servers , if you desire. Please refer Ruby [SDK documentation](https://github.com/opentok/OpenTok-Ruby-SDK) for that. 
In this case, as in the
HelloWorld sample app, there is only one session created and it is used here and for the participant
view. This will trigger the broadcasting to begin. The response sent back to the client's XHR request
will be the JSON representation of the archive, which is returned from the `to_json()` method. 

You can view the HLS broadcast by going to your Home page in a different tab and clicking on `Broadcast URL` button.
The code for handling this is as follows:
```ruby
  get '/broadcast' do
    broadcast = settings.opentok.broadcasts.find settings.broadcastId
    redirect broadcast.broadcastUrls['hls'] if broadcast.status == 'started'
  end
```
The Stop Broadcast code looks like:

```ruby
  get '/stop/:broadcastId' do
    broadcast = settings.opentok.broadcasts.stop settings.broadcastId
    settings.broadcast = nil
    settings.focusStreamId = ''
    settings.broadcastLayout = 'bestFit'
    body broadcast.to_json
  end
```
The settings revert backs to the settings when you start the app.

In the host page, you also have a button called `Toggle Layout`, which toggles between `verticalPresentation` and 
`horizontalPresentation`. We use the `bestFit` as the initial starting layout (This can be changed to whatever you want).
The route for `Toggle Layout` has the following code:

```ruby
  post '/broadcast/:broadcastId/layout' do
    layoutType = params[:type]
    settings.opentok.broadcasts.layout(settings.broadcastId, type: layoutType)
    settings.broadcastLayout = layoutType
  end
```

### Creating Broadcast - Participant View

With the host view still open and publishing, open an additional  tab and navigate to
<http://localhost:4567/participant> and allow the browser to use your camera and microphone. You will now see
the participant in your broadcasts.


```ruby
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
```

### Changing streams layout class
If you click on either the host or the participant video/view, that view gets the `focus` and `full` view layout
in the broadcast. The JS pages send `focus` stream id and the `other` streams layout can be `nulled`
out, as shown below:

```ruby
  post '/focus' do
    hash = { items: [] }
    hash[:items] << { id: params[:focus], layoutClassList: ['focus', 'full'] }
    settings.focusStreamId = params[:focus]
    if params.key?('otherStreams')
      params[:otherStreams].each do |stream|
        hash[:items] << { id: stream, layoutClassList: [] }
      end
    end
    settings.opentok.streams.layout(settings.session.session_id, hash)
  end
``` 

That completes the walkthrough for this Broadcast sample application. 