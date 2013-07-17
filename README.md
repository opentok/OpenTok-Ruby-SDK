# Opentok

OpenTok is an API from TokBox that enables websites to weave live group video communication into their online experience. Check out <http://www.tokbox.com/> for more information.  
This is the official OpenTok Ruby Server SDK for generating Sessions, Tokens, and retriving Archives. Please visit our [getting started page](http://www.tokbox.com/opentok/tools/js/gettingstarted) if you are unfamiliar with these concepts.  

## Installation

To install using bundler, add Opentok to your `gemfile` and run `bundle install`:
<pre>
gem 'opentok'
</pre>

To install as a regular gem just type `gem install opentok`

## Requirements

You need an api-key and secret. Sign up at <http://www.tokbox.com/opentok/tools/js/apikey>.

# OpenTokSDK

In order to use any of the server side functions, you must first create an `OpenTokSDK` object with your developer credentials.  
`OpenTokSDK` takes 2 parameters:
> key (string) - Given to you when you register  
> secret (string) - Given to you when you register  

<pre>
# Creating an OpenTok Object
API_KEY = ''                # should be a string
API_SECRET = ''            # should be a string
OTSDK = OpenTok::OpenTokSDK.new API_KEY, API_SECRET
</pre>


## Creating Sessions
Use your `OpenTokSDK` object to create `session_id`  
`createSession` takes 1-2 parameters:
> location (string) -  OPTIONAL. a location so OpenTok can stream through the closest server  
> properties (object) - OPTIONAL. Set peer to peer as `enabled` or `disabled`. Disabled by default  

<pre>
# creating a simple session: closest streaming server will be automatically determined when user connects to session
sessionId = OTSDK.createSession().to_s

# Creating Session object, passing request IP address to determine closest production server
sessionId = OTSDK.createSession( request.remote_ip ).to_s

# Creating Session object with p2p enabled
sessionProperties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}    # or disabled
sessionId = OTSDK.createSession( @location, sessionProperties ).to_s
</pre>

## Generating Tokens
With the generated sessionId, you can start generating tokens for each user.
`generate_token` takes in hash with 1-4 properties:
> session_id (string) - REQUIRED  
> role (string) - OPTIONAL. subscriber, publisher, or moderator  
> expire_time (int) - OPTIONAL. Time when token will expire in unix timestamp  
> connection_data (string) - OPTIONAL. Metadata to store data (names, user id, etc)

<pre>
# Generating a token
token = OTSDK.generateToken :session_id => session, :role => OpenTok::RoleConstants::PUBLISHER, :connection_data => "username=Bob,level=4"
</pre>

Possible Errors:
> "Null or empty session ID are not valid"  
> "An invalid session ID was passed"

## Manipulating Archive Videos
To Download or delete archived video, you must have an Archive ID which you get from the javascript library. If you are unfamiliar with archiving concepts, please visit our [archiving tutorial](http://www.tokbox.com/opentok/api/documentation/gettingstartedarchiving)  

## Delete Archives
OpenTok SDK has a function `deleteArchive` that lets you delete videos in a recorded archive. 
Use your `OpenTokSDK` object to call `deleteArchive`
`deleteArchive` takes in 2 parameters and returns a true or false boolean representing the success of the delete request
> archive_id (string) - REQUIRED  
> token (string) - REQUIRED. This token MUST have a moderator role, and it should be generated with the same session_id used to create the archive  
> **returns**  
  true: Success, the archive is deleted  
  false: Archive does not exist (perhaps it was already deleted or never created), invalid token (perhaps it does not have the moderator role or it's generated with the wrong session_id)

Example:
<pre>
successful = OTSDK.deleteArchive( archive_id, token )
</pre>

# Stitching Archives
OpenTok SDK allows you to stich up to 4 videos together in an archive.  
Use your `OpenTokSDK` object to call stitchArchive  
stitchArchive takes in 1 parameter and returns a hash object with code, message, and location if stitch is successful.  
> archive_id (string) - REQUIRED  
> **returns**:  
  {:code=>201, :message=>"Successfully Created", :location=>response["location"]}  
  {:code=>202, :message=>"Processing"}  
  {:code=>403, :message=>"Invalid Credentials"}  
  {:code=>404, :message=>"Archive Does Not Exist"}  
  {:code=>500, :message=>"Server Error"}  

Example:  
<pre>
result = OTSDK.stitchArchive archive_id
if result[:code] == 201
  return result[:location]
end
</pre>

# Get Archive Manifest
With your **moderator token** and OpentokSDK Object, you can generate OpenTokArchive Object, which contains information for all videos in the Archive  
`getArchiveManifest()` takes in 2 parameters: **archiveId** and **moderator token**  
> archive_id (string) - REQUIRED. 
> token (string) - REQUIRED. 
> **returns** an `OpenTokArchive` object.  
  The *resources* property of this object is array of `OpenTokArchiveVideoResource` objects, and each `OpenTokArchiveVideoResource` object represents a video in the archive.

Example:(Make sure you have the OpentokSDK Object)
<pre>
@token = '...'  # token generated with corresponding session
@archiveId = '5f74aee5-ab3f-421b-b124-ed2a698ee939' #Obtained from Javascript Library
otArchive = OTSDK.getArchiveManifest(@archiveId, @token)
</pre>

# Get video ID
`OpenTokArchive.resources` is an array of `OpenTokArchiveVideoResource` objects. OpenTokArchiveVideoResource has `getId()` method that returns the video_id  
`getId()` will return the video ID (a String)

Example:
<pre>
otArchive = OTSDK.getArchiveManifest(@archiveId, @token)
otVideoResource = otArchive.resources[0]
videoId = otVideoResource.getId()
</pre>

# Get Download Url
`OpenTokArchive` has `downloadArchiveURL` that will return an url string for downloading the video in the archive. You must call this function every time you want the file, because this url expires after 24 hours
> video_id (string) - REQUIRED  
> token (string) - REQUIRED  
> returns url string

Example:
<pre>
url = otArchive.downloadArchiveURL(video_id, token)
</pre>

-----

# Contributing
To contribute, simple fork this repository and send a pull request when you are done.  
Before you send pull requests, make sure all test cases are passing.  

To install necessary gems, type `bundle install` in the root directory.  

To run test cases, type `rspec spec/` in the root directory.   

-----

### Fun Fact:

To upload opentok gem, first update `opentok.gemspec` specs  
Build gem: `gem build opentok.gemspec`  
Push gem: `gem push opentok-*.gem`    
