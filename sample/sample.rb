require 'opentok'

API_KEY = ''    # See https://dashboard.tokbox.com/
API_SECRET = '' # See https://dashboard.tokbox.com/

OTSDK = OpenTok::OpenTokSDK.new API_KEY, API_SECRET

# Create an OpenTok server-enabled session
sessionId = OTSDK.createSession().to_s
print sessionId + "\n"

# Create a peer-to-peer session
sessionProperties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}    # or disabled
sessionId = OTSDK.createSession( nil, sessionProperties ).to_s
print sessionId + "\n"

# Generate a publisher token
token = OTSDK.generateToken :session_id => sessionId
print token + "\n"

# Generate a token with moderator role and connection data
role = OpenTok::RoleConstants::MODERATOR
connection_data = "username=Bob,level=4, score=8888888888"
token = OTSDK.generateToken :session_id => sessionId, :role => role, :connection_data => connection_data
print token + "\n"

