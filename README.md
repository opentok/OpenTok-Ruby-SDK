# OpenTok Server SDK for Ruby

The OpenTok server SDK for Ruby lets you generate [sessions](http://tokbox.com/opentok/tutorials/create-session/) and
[tokens](http://tokbox.com/opentok/tutorials/create-token/) for [OpenTok](http://www.tokbox.com/) applications.


## Installation

To install using bundler, add Opentok to your `Gemfile` and run `bundle install`:
<pre>
gem 'opentok'
</pre>

To install as a regular gem just type `gem install opentok`


## Requirements

The OpenTok server SDK for Ruby requires Ruby 1.9 or greater.

You need an OpenTok API key and API secret, which you can obtain at <https://dashboard.tokbox.com>.

# OpenTokSDK

In order to use any of the server side functions, you must first create an `OpenTokSDK` object with your developer credentials.  
`OpenTokSDK` takes two parameters:

* key (string) - Given to you when you register  
* secret (string) - Given to you when you register  

<pre>
# Creating an OpenTok Object
API_KEY = ''     # replace with your OpenTok API key
API_SECRET = ''  # replace with your OpenTok API secret
OTSDK = OpenTok::OpenTokSDK.new API_KEY, API_SECRET
</pre>

## Creating Sessions
Call the `create_session()` method of the `OpenTokSDK` object to create a session. The method returns a Session object.
The `session_id` property of the Session object is the OpenTok session ID:
<pre>
# creating an OpenTok server-enabled session
session_id = OTSDK.create_session().to_s

# Creating peer-to-peer session
session_properties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}
session_id = OTSDK.create_session( nil, session_properties ).to_s
</pre>

## Generating Tokens
With the generated session ID, you can generate tokens for each user:

<pre>
# Generating a publisher token
token = OTSDK.generate_token :session_id => session_id
 
# Generating a token with moderator role and connection data
role = OpenTok::RoleConstants::MODERATOR
connection_data = "username=Bob,level=4"
token = OTSDK.generate_token :session_id => session_id, :role => role, :connection_data => connection_data
</pre>

Possible Errors:

* "Null or empty session ID are not valid"  
* "An invalid session ID was passed"

# Contributing
To contribute, simple fork this repository and send a pull request when you are done.  
Before you send pull requests, make sure all test cases are passing.  

To install necessary gems, type `bundle install` in the root directory.  

To run test cases, type `rspec spec/` in the root directory.   


# More information

See the [reference documentation](doc/reference.md).

For more information on OpenTok, go to <http://www.tokbox.com/>.
