# Opentok

OpenTok is a free set of APIs from TokBox that enables websites to weave live group video communication into their online experience. With OpenTok you have the freedom and flexibility to create the most engaging web experience for your users. OpenTok is currently available as a JavaScript and ActionScript 3.0 library. Check out <http://www.tokbox.com/> and <http://www.tokbox.com/opentok/tools/js/gettingstarted> for more information.

This is the official Opentok rubygem.

## Installation

To install using bundler, add Opentok to your `gemfile` and run `bundle install`:
<pre>
gem 'opentok'
</pre>

To install as a regular gem just type `gem install opentok`

## How to use

### API-key and secret

Request your api-key and secret at <http://www.tokbox.com/opentok/tools/js/apikey>. You can use the staging environment for testing. The gem uses this staging environment by default.

### OpenTokSDK

In order to use any of the server side functions, you must first create an `OpenTokSDK` object with your developer credentials.  
You must pass in your *Key* and *Secret*. If your app is in production, you must also pass in a hash containing `api_url`  
For more information about production apps, check out <http://www.tokbox.com/opentok/api/tools/js/launch>

Example: ( Staging )
<pre>
@api_key = ''                # should be a string
@api_secret = ''            # should be a string
@opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret
</pre>

Example: ( Production )
<pre>
@opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret, :api_url => 'https://api.opentok.com/hl'
</pre>

### Creating Sessions
Use your `OpenTokSDK` object to create `session_id`  
`create_session` takes 1-2 parameters:
> location (string) -  give Opentok a hint on where you are running your application  
> properties (object) - OPTIONAL. Set peer to peer as `enabled` or `disabled`

Example: P2P disabled by default
<pre>
@location = 'localhost'
session_id = @opentok.create_session(@location)
</pre>

Example: P2P enabled
<pre>
session_properties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}    # or disabled
session_id = @opentok.create_session( @location, session_properties )
</pre>

### Generating Token
With the generated session_id, you can start generating tokens for each user.
`generate_token` takes in hash with 1-4 properties:
> session_id (string) - required  
> role (string) - OPTIONAL. subscriber, publisher, or moderator  
> expire_time (int) - OPTIONAL. Time when token will expire in unix timestamp  
> connection_data (string) - OPTIONAL. Metadata to store data (names, user id, etc)

Example:
<pre>
token = @opentok.generate_token :session_id => session, :role => OpenTok::RoleConstants::PUBLISHER, :connection_data => "username=Bob,level=4"
</pre>

### Downloading Archive Videos
To Download archives, first you must first create a token that has a **moderator** role

### Get Archive Manifest
`get_archive_manifest()` takes in 2 parameters: **archiveId** and **moderator token**  
> **returns** an `OpenTokArchive`. The *resources* property of this object is array of `OpenTokArchiveVideoResource`, and each `OpenTokArchiveVideoResource` object represents a video in the archive.

### Get video ID
With your `OpenTokArchive` object, call `getId()`
`getId()` will return the video ID (a String)

### Get Download Url
`downloadArchiveURL` takes 1 parameters: `video ID` and returns download URL for the video 
 

