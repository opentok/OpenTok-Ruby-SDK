# OpenTok Ruby SDK

[![Build Status](https://travis-ci.org/opentok/OpenTok-Ruby-SDK.png)](https://travis-ci.org/opentok/OpenTok-Ruby-SDK)

The OpenTok Ruby SDK lets you generate
[sessions](http://www.tokbox.com/opentok/tutorials/create-session/) and
[tokens](http://www.tokbox.com/opentok/tutorials/create-token/) for
[OpenTok](http://www.tokbox.com/) applications, and
[archive](https://tokbox.com/opentok/tutorials/archiving) OpenTok sessions.

# Installation

## Bundler (recommended):

Bundler helps manage dependencies for Ruby projects. Find more info here: <http://bundler.io>

Add this gem to your `Gemfile`:

```ruby
gem "opentok", "~> 3.0.3"
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

To create an OpenTok Session, use the `OpenTok#create_session(properties)` method. The
`properties` parameter is an optional Hash used to specify whether you are creating a session that
uses the OpenTok Media Server and specifying a location hint. The `session_id` method of the
returned `OpenTok::Session` instance is useful to get a sessionId that can be saved to a persistent
store (e.g. database).

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

## Working with Archives

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

For more information on archiving, see the
[OpenTok archiving](https://tokbox.com/opentok/tutorials/archiving/) programming guide.


## Initiating a SIP call

You can initiate a SIP call using the `opentok.sip.dial(session_id, token, sip_uri, opts)` method.  This requires a SIP url. You will often need to pass options for authenticating to the SIP provider and specifying encrypted session establishment.


```ruby
opts = { "auth" => { "username" => sip_username,
                     "password" => sip_password },
         "secure" => "true"
}
response = opentok.sip.dial(session_id, token, "sip:+15128675309@acme.pstn.example.com;transport=tls", opts)
```

For more information on SIP Interconnect, see the
[OpenTok SIP Interconnect](https://tokbox.com/developer/guides/sip/) programming guide.


# Samples

There are two sample applications included in this repository. To get going as fast as possible, clone the whole
repository and follow the Walkthroughs:

*  [HelloWorld](sample/HelloWorld/README.md)
*  [Archiving](sample/Archiving/README.md)

# Documentation

Reference documentation is available at <http://www.tokbox.com//opentok/libraries/server/ruby/reference/index.html>.

# Requirements

You need an OpenTok API key and API secret, which you can obtain at <https://dashboard.tokbox.com>.

The OpenTok Ruby SDK requires Ruby 1.9.3 or greater.

# Release Notes

See the [Releases](https://github.com/opentok/opentok-ruby-sdk/releases) page for details
about each release.

## Important changes since v2.2.0

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
