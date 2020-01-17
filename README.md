# OpenTok Ruby SDK

[![Build Status](https://travis-ci.org/opentok/OpenTok-Ruby-SDK.png)](https://travis-ci.org/opentok/OpenTok-Ruby-SDK)

The OpenTok Ruby SDK lets you generate
[sessions](https://tokbox.com/developer/guides/create-session/) and
[tokens](https://tokbox.com/developer/guides/create-token/) for
[OpenTok](http://www.tokbox.com/) applications. It also includes methods for
working with OpenTok [archives](https://tokbox.com/developer/guides/archiving),
working with OpenTok [live streaming
broadcasts](https://tokbox.com/developer/guides/broadcast/live-streaming/),
working with OpenTok [SIP interconnect](https://tokbox.com/developer/guides/sip),
and [disconnecting clients from sessions](https://tokbox.com/developer/guides/moderation/rest/).

# Installation

## Bundler (recommended):

Bundler helps manage dependencies for Ruby projects. Find more info here: <http://bundler.io>

Add this gem to your `Gemfile`:

```ruby
gem "opentok", "~> 4.0.0"
```

Allow bundler to install the change.

```
$ bundle install
```

## RubyGems:

```
$ gem install opentok
```

# Usage

## Initializing

Load the gem at the top of any file where it will be used. Then initialize an `OpenTok::OpenTok`
object with your OpenTok API key and API secret.

```ruby
require "opentok"

opentok = OpenTok::OpenTok.new api_key, api_secret
```

## Creating Sessions

To create an OpenTok Session, use the `OpenTok#create_session(properties)` method.
The `properties` parameter is an optional Hash used to specify the following:

* Whether the session uses the [OpenTok Media
  Router](https://tokbox.com/developer/guides/create-session/#media-mode),
  which is required for some OpenTok features (such as archiving)

* A location hint for the OpenTok server.

* Whether the session is automatically archived.

The `session_id` method of the returned `OpenTok::Session` instance is useful to
get a sessionId that can be saved to a persistent store (such as a database).

```ruby
# Create a session that will attempt to transmit streams directly between clients.
# If clients cannot connect, the session uses the OpenTok TURN server:
session = opentok.create_session

# A session that will use the OpenTok Media Server:
session = opentok.create_session :media_mode => :routed

# A session with a location hint:
session = opentok.create_session :location => '12.34.56.78'

# A session with automatic archiving (must use the routed media mode):
session = opentok.create_session :archive_mode => :always, :media_mode => :routed

# Store this sessionId in the database for later use:
session_id = session.session_id
```

## Generating Tokens

Once a Session is created, you can start generating Tokens for clients to use when connecting to it.
You can generate a token either by calling the `opentok.generate_token(session_id, options)` method,
or by calling the `Session#generate_token(options)` method on the instance after creating it. The
`options` parameter is an optional Hash used to set the role, expire time, and connection data of
the Token. For layout control in archives and broadcasts, the initial layout class list of streams
published from connections using this token can be set as well.

```ruby
# Generate a Token from just a session_id (fetched from a database)
token = opentok.generate_token session_id

# Generate a Token by calling the method on the Session (returned from createSession)
token = session.generate_token

# Set some options in a token
token = session.generate_token({
    :role        => :moderator,
    :expire_time => Time.now.to_i+(7 * 24 * 60 * 60), # in one week
    :data        => 'name=Johnny',
    :initial_layout_class_list => ['focus', 'inactive']
});
```

## Working with Streams 

Use this method to get information for an OpenTok stream or for all streams in a session.
For example, you can call this method to get information about layout classes used by an
OpenTok stream. 

To get information of a specific stream in a session, call
`opentok.streams.find(session_id, stream_id)`. The return object is a `Stream` object and
you can access various stream properties as shown in the following example (using RSpec notations):

```ruby
expect(stream).to be_an_instance_of OpenTok::Stream
expect(stream.videoType).to eq 'camera'
expect(stream.layoutClassList.count).to eq 1
expect(stream.layoutClassList.first).to eq "full"
```

To get information on all streams in a session, call `opentok.streams.all(session_id)`.
The return value is a `StreamList` object:

```ruby
expect(all_streams).to be_an_instance_of OpenTok::StreamList
expect(all_streams.total).to eq 2
expect(all_streams[0].layoutClassList[1]).to eq "focus"
```

## Working with Archives

You can only archive sessions that use the OpenTok Media Router
(sessions with the media mode set to routed).

You can start the recording of an OpenTok Session using the `opentok.archives.create(session_id,
options)` method. This will return an `OpenTok::Archive` instance. The parameter `options` is an
optional Hash used to set the `has_audio`, `has_video`, and `name` options. Note that you can
only start an Archive on a Session that has clients connected.

```ruby
# Create an Archive
archive = opentok.archives.create session_id

# Create a named Archive
archive = opentok.archives.create session_id :name => "Important Presentation"

# Create an audio-only Archive
archive = opentok.archives.create session_id :has_video => false

# Store this archive_id in the database for later use
archive_id = archive.id
```

Setting the `:output_mode` option to `:individual` setting causes each stream in the archive
to be recorded to its own individual file:

```ruby
archive = opentok.archives.create session_id :output_mode => :individual
```

The `:output_mode => :composed` setting (the default) causes all streams in the archive to be
recorded to a single (composed) file.

For composed archives you can set the resolution of the archive, either "640x480" (SD, the default)
or "1280x720" (HD). The `resolution` parameter is optional and could be included in the options
hash (second argument) of the `opentok.archives.create()` method. 

```ruby
opts = {
    :output_mode => :composed,
    :resolution => "1280x720"
}

archive = opentok.archives.create session_id, opts
```

To customize the initial layout of composed archives, you can use the `:layout` option.
Set this to a hash containing two keys: `:type` and `:stylesheet`. Valid values for
`:type` are "bestFit" (best fit), "custom" (custom), "horizontalPresentation"
(horizontal presentation), "pip" (picture-in-picture), and "verticalPresentation"
(vertical presentation)). If you specify a "custom" layout type, set the `:stylesheet`
key to the stylesheet (CSS). (For other layout types, do not set the `:stylesheet` key.)

```ruby
opts = {
    :output_mode => :composed,
    :resolution => "1280x720",
    :layout => {
      :type => "custom",
      :stylesheet => "stream:last-child{display: block;margin: 0;top: 0;left: 0;width: 1px;height: 1px;}stream:first-child{display: block;margin: 0;top: 0;left: 0;width: 100%;height: 100%;}"
    }
}

archive = opentok.archives.create session_id, opts
```

If you do not specify an initial layout type, the archive uses the best fit
layout type. For more information, see [Customizing the video layout for composed
archives](https://tokbox.com/developer/guides/archiving/layout-control.html).

You can stop the recording of a started Archive using the `opentok.archives.stop_by_id(archive_id)`
method. You can also do this using the `Archive#stop()` method.

```ruby
# Stop an Archive from an archive_id (fetched from database)
opentok.archives.stop_by_id archive_id

# Stop an Archive from an instance (returned from opentok.archives.create)
archive.stop
```

To get an `OpenTok::Archive` instance (and all the information about it) from an `archive_id`, use
the `opentok.archives.find(archive_id)` method.

```ruby
archive = opentok.archives.find archive_id
```

To delete an Archive, you can call the `opentok.archives.delete_by_id(archive_id)` method or the
`delete` method of an `OpenTok::Archive` instance.

```ruby
# Delete an Archive from an archive_id (fetched from database)
opentok.archives.delete_by_id archive_id

# Delete an Archive from an Archive instance (returned from archives.create, archives.find)
archive.delete
```

You can also get a list of all the Archives you've created (up to 1000) with your API Key. This is
done using the `opentok.archives.all(options)` method. The parameter `options` is an optional Hash
used to specify an `:offset` and `:count` to help you paginate through the results. This will return
an instance of the `OpenTok::ArchiveList` class.

```ruby
archive_list = opentok.archives.all

# Get an specific Archive from the list
archive_list[i]

# Get the total number of Archives for this API Key
$total = archive_list.total
```

Note that you can also create an automatically archived session, by passing in `:always`
as the `:archive_mode` property of the `options` parameter passed into the
`OpenTok#create_session()` method (see "Creating Sessions," above).

You can set the [layout](https://tokbox.com/developer/rest/#change_composed_archive_layout) of an archive:

```ruby
opts = { :type => "verticalPresentation" }
opentok.archives.layout(archive_id, opts)
```

The hash `opts` has two entries:

* The `type` is the layout type for the archive.  Valid values are "bestFit" (best fit)
  "custom" (custom), "horizontalPresentation" (horizontal presentation),
  "pip" (picture-in-picture), and "verticalPresentation" (vertical presentation)).

* If you specify a "custom" layout type, set the `stylesheet` property. 
  (For other layout types, do not set the stylesheet property.) 

See [Customizing the video layout for composed archives](https://tokbox.com/developer/guides/archiving/layout-control.html)
for more details. 

You can set the initial layout class for a client's streams by setting the layout option when you
create the token for the client, using the `opentok.generate_token` method. And you can also change
the layout classes of a stream as follows:

```ruby
streams_list = {
    :items => [
        {
            :id => "8b732909-0a06-46a2-8ea8-074e64d43422",
            :layoutClassList => ["full"]
        },
        {
            :id => "8b732909-0a06-46a2-8ea8-074e64d43423",
            :layoutClassList => ["full", "focus"]
        }
    ]
}
response = opentok.streams.layout(session_id, streams_list)
```

For more information on setting stream layout classes, see the
[Changing the composed archive layout classes for an OpenTok
stream](https://tokbox.com/developer/rest/#change-stream-layout-classes-composed).

Please keep in mind that the `streams.layout` method applies to archive and broadcast streams only. 

For more information on archiving, see the
[OpenTok archiving](https://tokbox.com/opentok/tutorials/archiving/) programming guide.

## Signaling

You can send a signal using the `opentok.signals.send(session_id, connection_id, opts)` method.  
If `connection_id` is nil or an empty string, then the signal is send to all valid connections in
the session. 

An example of `opts` field can be as follows:

```ruby
opts = { :type => "chat",
         :data => "Hello"
}
```

The maximum length of the `type` string is 128 bytes, and it must contain only letters
(A-Z and a-z), numbers (0-9), '-', '_', and '~'.

The `data` string must not exceed the maximum size (8 kB).

The `connection_id` and `opts` parameter are jointly optional by default. Hence you can also 
use `opentok.signals.send(session_id)`

For more information on signaling, see the
[OpenTok Signaling](https://tokbox.com/developer/guides/signaling/js/) programming guide.

## Broadcasting

You can broadcast your streams to a HLS or RTMP servers.

To successfully start broadcasting a session, at least one publishing client must be connected to
the session.

You can only have one active live streaming broadcast at a time for a session (however, having more
than one would not be useful). 

The live streaming broadcast can target one HLS endpoint and up to five RTMP servers simultaneously
for a session. 

You can only start live streaming for sessions that use the OpenTok Media Router (with the
media mode set to routed). You cannot use live streaming with sessions that have the media mode set
to relayed.

To create a HLS only broadcast:
```ruby
opts = {
  :outputs => {
      :hls => {}
  }
}
broadcast = opentok.broadcasts.create(session_id, opts)

# HLS + RTMP
opts = {
   :outputs => {
       :hls => {},
       :rtmp => [
           {
               :id => "myOpentokStream",
               :serverUrl => "rtmp://x.rtmp.youtube.com/live123",
               :streamName => "66c9-jwuh-pquf-9x00"
           }
       ]
   }
}
broadcast = opentok.broadcasts.create(session_id, opts)
```

The returned Broadcast object has information about the broadcast, like id, sessionId , projectId,
createdAt, updatedAt, resolution, status, and a Hash of broadcastUrls. The broadcastUrls 
consists of an HLS URL and an array of RTMP objects. The RTMP objects resembles the `rtmp` value
in `opts` in the example above. 

For more information on broadcast, see the
[OpenTok Broadcast guide](https://tokbox.com/developer/rest/#start_broadcast) programming guide.

To get information about a broadcast stream 
```ruby
my_broadcast = opentok.broadcasts.find broadcast_id
```
The Broadcast object returned has properties describing the broadcast, like id, sessionId,
projectId, createdAt, updatedAt, resolution, status, and a Hash of broadcastUrls. The broadcastUrls 
consists of an HLS URL and an array of RTMP objects. The RTMP objects resembles the `rtmp` value
in `opts` in the example above. 

To stop a broadcast:

```ruby
 my_broadcast = opentok.broadcasts.stop broadcast_id
 
 # stop at a broadcast object level too
 # 
 my_broadcast = opentok.broadcasts.find broadcast_id
 ret_broadcast =  my_broadcast.stop
 
 # Both the above returned objects has the "broadcastUrls" property as a nil value and the status 
 # property value is "stopped"
```


To change the layout of a broadcast dynamically 
```ruby
opentok.broadcasts.layout(started_broadcast_id, {
        :type => "verticalPresentation"
    })
    
  # On an object level
   my_broadcast = opentok.broadcasts.find broadcast_id
   my_broadcast.layout(
             :type => 'pip',
             )

   # the returned value is true if successful
```

The hash above has two entries.

* The `type` is the layout type for the archive. Valid values are "bestFit" (best fit),
  "custom" (custom), "horizontalPresentation" (horizontal presentation),
  "pip" (picture-in-picture), and "verticalPresentation" (vertical presentation). 

* If you specify a "custom" layout type, set the `stylesheet` property.  (For other layout types,
  do not set the stylesheet property.) 

Refer to [Customizing the video layout for composed
archives](https://tokbox.com/developer/guides/archiving/layout-control.html)
for more details. 

You can also change the layout of an individual stream dynamically. Refer to
[working with Streams](#working-with-streams).

## Force disconnect 

You can cause a client to be forced to disconnect from a session by using the
`opentok.connections.forceDisconnect(session_id, connection_id)` method.

## Initiating a SIP call

You can initiate a SIP call using the `opentok.sip.dial(session_id, token, sip_uri, opts)` method. 
This requires a SIP URL. You will often need to pass options for authenticating to the SIP provider
and specifying encrypted session establishment.

```ruby
opts = { "auth" => { "username" => sip_username,
                     "password" => sip_password },
         "secure" => "true"
}
response = opentok.sip.dial(session_id, token, "sip:+15128675309@acme.pstn.example.com;transport=tls", opts)
```

For more information on SIP Interconnect, see the
[OpenTok SIP Interconnect](https://tokbox.com/developer/guides/sip/) developer guide.


# Samples

There are two sample applications included in this repository. To get going as fast as possible, clone the whole
repository and follow the Walkthroughs:

*  [HelloWorld](sample/HelloWorld/README.md)
*  [Archiving](sample/Archiving/README.md)

# Documentation

Reference documentation is available at <http://www.tokbox.com//opentok/libraries/server/ruby/reference/index.html>.

# Requirements

You need an OpenTok API key and API secret, which you can obtain by logging into your
[TokBox account](https://tokbox.com/account).

The OpenTok Ruby SDK requires Ruby 2.1.0 or greater.

# Release Notes

See the [Releases](https://github.com/opentok/opentok-ruby-sdk/releases) page for details
about each release.

## Important changes since v2.2.0

**Changes in v4.0.0:**

The SDK adds support for Ruby v2.7 and now requires Ruby v2.1.0 or higher.
For Ruby v2.0.0 please continue to use the OpenTok Ruby SDK v3.0.0.
For Ruby v1.9.3 please continue to use the OpenTok Ruby SDK v2.5.0. 

**Changes in v3.0.0:**

The SDK now now requires Ruby v2.0.0 or higher. For Ruby v1.9.3 please continue to use the
OpenTok Ruby SDK v2.5.0.

**Changes in v2.2.2:**

The default setting for the `create_session()` method is to create a session with the media mode set
to relayed. In previous versions of the SDK, the default setting was to use the OpenTok Media Router
(media mode set to routed). In a relayed session, clients will attempt to send streams directly
between each other (peer-to-peer); if clients cannot connect due to firewall restrictions, the
session uses the OpenTok TURN server to relay audio-video streams.

**Changes in v2.2.0:**

This version of the SDK includes support for working with OpenTok archives.

Note also that the `options` parameter of the `OpenTok.create_session()` method has a `media_mode`
property instead of a `p2p` property.

See the reference documentation
<http://www.tokbox.com/opentok/libraries/server/ruby/reference/index.html> and in the
docs directory of the SDK.


# Development and Contributing

Interested in contributing? We :heart: pull requests! See the [Development](DEVELOPING.md) and
[Contribution](CONTRIBUTING.md) guidelines.

# Support

See <https://support.tokbox.com> for all our support options.

Find a bug? File it on the [Issues](https://github.com/opentok/opentok-ruby-sdk/issues) page. Hint:
test cases are really helpful!
