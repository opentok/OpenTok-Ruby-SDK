# OpenTok Server SDK for Ruby

The OpenTok server SDK for Ruby lets you generate [sessions](http://tokbox.com/opentok/tutorials/create-session/) and
[tokens](http://tokbox.com/opentok/tutorials/create-token/) for [OpenTok](http://www.tokbox.com/) applications.
This version of the SDK also includes support for working with OpenTok 2.0 archives.


## Installation

To install using bundler, add Opentok to your `gemfile` and run `bundle install`:
<pre>
gem 'opentok'
</pre>

To install as a regular gem just type `gem install opentok`


## Requirements

The OpenTok server SDK for Ruby requires Ruby 1.9 or greater.

You need an OpenTok API key and API secret, which you can obtain at <https://dashboard.tokbox.com>.

## Changes in v2.0 of the OpenTok Ruby SDK

This version of the SDK includes support for working with OpenTok 2.0 archives. (This API does not work
with OpenTok 1.0 archives.)

## OpenTokSDK

In order to use any of the server-side functions, you must first create an `OpenTokSDK` object with
your developer credentials. `OpenTokSDK` takes two parameters:

* key (string) - Your OpenTok API key
* secret (string) - Your OpenTok API secret

<pre>
# Creating an OpenTok Object
API_KEY = ''     # replace with your OpenTok API key
API_SECRET = ''  # replace with your OpenTok API secret
OTSDK = OpenTok::OpenTokSDK.new API_KEY, API_SECRET
</pre>

## Creating Sessions
Call the `createSession()` method of the `OpenTokSDK` object to create a session. The method returns a Session object.
The `sessionId` property of the Session object is the OpenTok session ID:
<pre>
# creating an OpenTok server-enabled session
sessionId = OTSDK.createSession().to_s

# Creating peer-to-peer session
sessionProperties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}
sessionId = OTSDK.createSession( nil, sessionProperties ).to_s
</pre>

## Generating Tokens
With the generated session ID, you can generate tokens for each user:

<pre>
# Generating a publisher token
token = OTSDK.generateToken :session_id => sessionId
 
# Generating a token with moderator role and connection data
role = OpenTok::RoleConstants::MODERATOR
connection_data = "username=Bob,level=4"
token = OTSDK.generateToken :session_id => sessionId, :role => role, :connection_data => connection_data
</pre>

Possible Errors:

* "Null or empty session ID are not valid"  
* "An invalid session ID was passed"

## Archiving

The following code starts recording an archive of an OpenTok 2.0 session
and returns the archive ID (on success). Note that you can only start an archive
on a session that has clients connected.

<pre>
session_id = session_id # Replace with an OpenTok session ID.
name = "archive-" + Time.new.inspect

begin
  archive = OTSDK.archives.create session_id, :name => name
rescue Exception => msg
  print msg, "\n"
end
</pre>

The following code stops the recording of an archive, returning
true on success, and false on failure.

<pre>
archive_id = "" # Replace with a valid archive ID.

begin
  archive = OTSDK.archives.find(archive_id).stop
rescue Exception => msg
  print msg, "\n"
end
</pre>

The following code deletes a given archive.

<pre>
archive_id = "" # Replace with a valid archive ID.
archive = OTSDK.archives.find(archive_id).delete
</pre>

The following method logs information on a given archive.

<pre>
archive_id = "" # Replace with a valid archive ID.

begin
  archive = OTSDK.archives.find archive_id
  archive.each do |key, value|
    puts "#{key}: #{value}\n"
  end
rescue Exception => msg
  print msg, "\n"
end
</pre>

The following code logs the archive IDs of all archives (up to 1000)
for your API key.

<pre>
archive_list = OTSDK.archives.all
archive_list.each do |archive|
  print archive.id + "\n"
end
</pre>


## Contributing
To contribute, simple fork this repository and send a pull request when you are done.  
Before you send pull requests, make sure all test cases are passing.  

To install necessary gems, type `bundle install` in the root directory.  

To run test cases, type `rspec spec/` in the root directory.   


## More information

See the [reference documentation](doc/reference.md).

For more information on OpenTok, go to <http://www.tokbox.com/>.
