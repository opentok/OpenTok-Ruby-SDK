require 'spec_helper'

describe OpenTok do
  
  before :all do
    @api_key = 394281
    @api_secret = '***REMOVED***'
    @api_staging_url = 'https://staging.tokbox.com/hl'
    @api_production_url = 'https://api.opentok.com/hl'
    @host = 'localhost'
    
    @opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret
  end
  
  it "should be possible to valid a OpenTokSDK object with a valid key and secret" do
    @opentok.should be_instance_of OpenTok::OpenTokSDK
  end
  
  it "a new OpenTokSDK object should point to the staging environment by default" do
    @opentok.api_url.should eq @api_staging_url
  end
  
  it "should be possible to generate a valid API token with a valid key and secret" do
    opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret
    session = opentok.create_session @host
    
    session.to_s.should match(/[0-9a-f]{40}/)
  end
  
  it "should raise an exception with an invalid key and secret" do
    opentok = OpenTok::OpenTokSDK.new 0, ''
    
    expect{
      session = opentok.create_session @host
    }.to raise_error OpenTok::OpenTokException
  end
  
  it "should be possible to set the api url as an option" do
    opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret, :api_url => @api_production_url
    
    opentok.api_url.should_not eq @api_staging_url
    opentok.api_url.should eq @api_production_url
    
    opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret, :api_url => @api_staging_url
    
    opentok.api_url.should_not eq @api_production_url
    opentok.api_url.should eq @api_staging_url
  end
end