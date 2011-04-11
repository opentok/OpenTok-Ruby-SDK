require 'spec_helper'

describe OpenTok do
  
  before :all do
    @api_key = 0
    @api_secret = ''
    @api_staging_url = 'https://staging.opentok.com/hl'
    @api_production_url = 'https://api.opentok.com/hl'
    
    @opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret
    # o.api_url = 'https://staging.opentok.com/hl'
    # print o.create_session '127.0.0.1'
  end
  
  it "should be possible to valid a OpenTokSDK object with a valid key and secret" do
    @opentok.should be_instance_of OpenTok::OpenTokSDK
  end
  
  it "a new OpenTokSDK object should point to the staging environment by default" do
    @opentok.api_url.should be @api_staging_url
  end
  
  it "should be possible to generate a valid API token with a valid key and secret" do
    opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret
  end
  
end