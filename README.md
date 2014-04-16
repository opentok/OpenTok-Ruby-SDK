# OpenTok Ruby SDK

**TODO**: got to change this to opentok fork instead of aoberoi

[![Build Status](https://travis-ci.org/aoberoi/Opentok-Ruby-SDK.png?branch=modernization)](https://travis-ci.org/aoberoi/Opentok-Ruby-SDK)

The OpenTok Ruby SDK lets you generate
[sessions](http://tokbox.com/opentok/tutorials/create-session/) and
[tokens](http://tokbox.com/opentok/tutorials/create-token/) for [OpenTok](http://www.tokbox.com/)
applications. This version of the SDK also includes support for working with OpenTok 2.0 archives.

# Installation

## Bundler (recommended):

Bundler helps manage dependencies for Ruby projects. Find more info here: <http://bundler.io>

Add this gem to your `Gemfile`:

```ruby
gem "opentok", "~> 2.2.x"
```

Allow bundler to install the change.

```
$ bundle install
```

## RubyGems:

```
$ gem install opentok -v 2.2.0pre
```

## Manually:

**TODO**: download from releases page?

# Usage

## Initializing

Load the gem at the top of any file where it will be used. Then initialize an `OpenTok::OpenTok`
object with your own API Key and API Secret.

```ruby
require "opentok"

opentok = OpenTok::OpenTok.new api_key, api_secret
```

## Creating Sessions

To create an OpenTok Session, use the `opentok.create_session(properties)` method. The 
`properties` parameter is an optional Hash used to specify whether you are creating a p2p Session
and specifying a location hint. The `session_id` method of the returned `OpenTok::Session`
instance is useful to get a sessionId that can be saved to a persistent store (e.g. database).

```ruby
# Just a plain Session
session = opentok.create_session
# A p2p Session
session = opentok.create_session :p2p => true
# A Session with a location hint
session = opentok.create_session :location => '12.34.56.78'

# Store this sessionId in the database for later use
session_id = session.session_id
```

## Generating Tokens

Once a Session is created, you can start generating Tokens for clients to use when connecting to it.
You can generate a token either by calling the `opentok.generate_token(session_id, options)` method,
or by calling the `session.generate_token(options)` method on the an instance after creating it. The
`options` parameter is an optional Hash used to set the role, expire time, and connection data of
the Token.

```ruby
# Generate a Token from just a session_id (fetched from a database)
token = opentok.generate_token session_id
# Generate a Token by calling the method on the Session (returned from createSession)
token = session.generate_token

# Set some options in a token
token = session.generate_token({
    :role        => :moderator
    :expire_time => Time.now.to_i+(7 * 24 * 60 * 60) # in one week
    :data        => 'name=Johnny'
});
```

## Working with Archives

You can start the recording of an OpenTok Session using the `opentok.archives.create(session_id,
options)` method. This will return an `OpenTok::Archive` instance. The parameter `options` is an
optional Hash used to assign a name for the Archive. Note that you can only start an
Archive on a Session that has clients connected.

```ruby
archive = opentok.archives.create session_id :name => "Important Presentation"

# Store this archive_id in the database for later use
archive_id = archive.id
```

You can stop the recording of a started Archive using the `opentok.archives.stop_by_id(archive_id)`
method. You can also do this using the `archive.stop` method of the `OpenTok::Archive` instance.

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

# Documentation

**TODO**: Reference documentation is available at <http://opentok.github.io/opentok-ruby-sdk/>

# Requirements

You need an OpenTok API key and API secret, which you can obtain at <https://dashboard.tokbox.com>.

The OpenTok Ruby SDK requires Ruby 1.9.3 or greater.

# Release Notes

**TODO**: See the [Releases](https://github.com/opentok/opentok-ruby-sdk/releases) page for details 
about each release.

## Important changes in v2.0

This version of the SDK includes support for working with OpenTok 2.0 archives. (This API does not
work with OpenTok 1.0 archives.)

# Development and Contributing

Interested in contributing? We <3 pull requests! File a new
[Issue](https://github.com/opentok/opentok-ruby-sdk/issues) or take a look at the existing ones. If
you are going to send us a pull request, please try to run the test suite first and also include
tests for your changes.

# Support

See <http://tokbox.com/opentok/support/> for all our support options.

Find a bug? File it on the [Issues](https://github.com/opentok/opentok-ruby-sdk/issues) page. Hint:
test cases are really helpful!
