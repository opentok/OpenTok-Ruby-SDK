# Opentok

OpenTok is an API from TokBox that enables websites to weave live group video communication into their online experience. Check out <http://www.tokbox.com/> for more information.  
This is the official OpenTok Ruby Server SDK for generating Sessions, Tokens, and retriving Archives. Please visit our [getting started page](http://www.tokbox.com/opentok/tools/js/gettingstarted) if you are unfamiliar with these concepts.  

## Installation

To install using bundler, add Opentok to your `gemfile` and run `bundle install`:
<pre>
gem 'opentok'
</pre>

To install as a regular gem just type `gem install opentok`

# Requirements

You need an api-key and secret. Request them at <http://www.tokbox.com/opentok/tools/js/apikey>.  

# OpenTokSDK

In order to use any of the server side functions, you must first create an `OpenTokSDK` object with your developer credentials.  

`OpenTokSDK` takes 2-3 parameters:
> key (string) - Given to you when you register  
> secret (string) - Given to you when you register  
> Production (Boolean) - OPTIONAL. Puts your app in staging or production environment. Default value is `false`  
For more information about production apps, check out <http://www.tokbox.com/opentok/api/tools/js/launch>


<pre>
# Creating an OpenTok Object in Staging Environment
API_KEY = ''                # should be a string
API_SECRET = ''            # should be a string
OTSDK = OpenTok::OpenTokSDK.new API_KEY, API_SECRET

# Creating an OpenTok Object in Production Environment
OTSDK = OpenTok::OpenTokSDK.new API_KEY, API_SECRET, true
</pre>


# Creating Sessions
Use your `OpenTokSDK` object to create `session_id`  
`createSession` takes 1-2 parameters:
> location (string) -  give Opentok a hint on where you are running your application  
> properties (object) - OPTIONAL. Set peer to peer as `enabled` or `disabled`. Disabled by default

<pre>
# Creating Session object, passing request IP address to determine closest production server
session_id = OTSDK.createSession( request.ip )

# Creating Session object with p2p enabled
sessionProperties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}    # or disabled
sessionId = OTSDK.createSession( @location, sessionProperties )
</pre>

# Generating Token
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

### Downloading Archive Videos
To Download archived video, you must have an Archive ID which you get from the javascript library

#### Quick Overview of the javascript library: <http://www.tokbox.com/opentok/api/tools/js/documentation/api/Session.html#createArchive>
1. Create an event listener on `archiveCreated` event: `session.addEventListener('archiveCreated', archiveCreatedHandler);`  
2. Create an archive: `archive = session.createArchive(...);`  
3. When archive is successfully created `archiveCreatedHandler` would be triggered. An Archive object containing `archiveId` property is passed into your function. Save this in your database, this archiveId is what you use to reference the archive for playbacks and download videos  
4. After your archive has been created, you can start recording videos into it by calling `session.startRecording(archive)`  
 Optionally, you can also use the standalone archiving, which means that each archive would have only 1 video: <http://www.tokbox.com/opentok/api/tools/js/documentation/api/RecorderManager.html>

### Stitching Archives
OpenTok SDK allows you to stich up to 4 videos together in an archive. Calling the stitchArchive function will return an object containing mp4 file of all the streams combined.  
`result = OTSDK.stitchArchive archive_id`
> archive_id (string) - REQUIRED  
Return:
  {:code=>201, :message=>"Successfully Created", :location=>response["location"]}
  {:code=>202, :message=>"Processing"}
  {:code=>403, :message=>"Invalid Credentials"}
  {:code=>404, :message=>"Archive Does Not Exist"}
  {:code=>500, :message=>"Server Error"}

### Get Archive Manifest
With your **moderator token** and OpentokSDK Object, you can generate OpenTokArchive Object, which contains information for all videos in the Archive  
`get_archive_manifest()` takes in 2 parameters: **archiveId** and **moderator token**  
> archive_id (string) - REQUIRED. 
> **returns** an `OpenTokArchive` object. The *resources* property of this object is array of `OpenTokArchiveVideoResource` objects, and each `OpenTokArchiveVideoResource` object represents a video in the archive.

Example:(Make sure you have the OpentokSDK Object)
<pre>
@token = 'moderator_token'
@archiveId = '5f74aee5-ab3f-421b-b124-ed2a698ee939' #Obtained from Javascript Library
otArchive = OTSDK.get_archive_manifest(@archiveId, @token)
</pre>

### Get video ID
`OpenTokArchive.resources` is an array of `OpenTokArchiveVideoResource` objects. OpenTokArchiveVideoResource has `getId()` method that returns the videoId
`getId()` will return the video ID (a String)

Example:
<pre>
otArchive = OTSDK.get_archive_manifest(@archiveId, @token)
otVideoResource = otArchive.resources[0]
videoId = otVideoResource.getId()
</pre>

### Get Download Url
`OpenTokArchive` has `downloadArchiveURL` that will return an url string for downloading the video in the archive. You must call this function every time you want the file, because this url expires after 24 hours
> video_id (string) - REQUIRED  
> token (string) - REQUIRED  
> returns url string

Example:
<pre>
url = otArchive.downloadArchiveURL(video_id, token)
</pre>
