require 'spec_helper'

class TestOpentokSDK < OpenTok::OpenTokSDK
  def do_request(api_url, params, token=nil)
    super
  end
end

describe OpenTok do
  
  before :all do
    @api_key = '459782'
    @api_secret = 'b44c3baa32b6476d9d88e8194d0eb1c6b777f76b'
    @api_staging_url = 'https://staging.tokbox.com/hl'
    @api_production_url = 'https://api.opentok.com/hl'
    @host = 'localhost'
    
    @opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret
  end

  describe "Staging Environment" do
    before :all do
      @api_key = '14971292'
      @api_secret = 'ecbe2b25afec7887bd72fe4763b87add8ce02658'
      @opentok = TestOpentokSDK.new @api_key, @api_secret
      @opts = {:partner_id => @api_key, :location=>@host}
    end

    it "should be possible to valid a OpenTokSDK object with a valid key and secret" do
      @opentok.should be_instance_of TestOpentokSDK
    end
    
    it "a new OpenTokSDK object should point to the staging environment by default" do
      @opentok.api_url.should eq @api_staging_url
    end

    it "should generate a valid session" do
      session = @opentok.create_session @host
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end

    it "do_request should respond with valid p2p" do
      @opts.merge!({'p2p.preference' => 'enabled'})
      doc = @opentok.do_request("/session/create", @opts)
      doc.root.get_elements('Session')[0].get_elements('properties')[0].get_elements('p2p')[0].get_elements('preference')[0].children[0].to_s.should =='enabled'
    end
  end

  describe "Production Environment" do
    before :all do
      @api_key = '11421872'
      @api_secret = '296cebc2fc4104cd348016667ffa2a3909ec636f'
      @opentok = TestOpentokSDK.new @api_key, @api_secret, {:api_url=>@api_production_url}
      @opts = {:partner_id => @api_key, :location=>@host}
    end

    it "should be possible to valid a OpenTokSDK object with a valid key and secret" do
      @opentok.should be_instance_of TestOpentokSDK
    end
    
    it "a new OpenTokSDK object should point to the staging environment by default" do
      @opentok.api_url.should eq @api_production_url
    end

    it "should generate a valid session" do
      session = @opentok.create_session @host
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end

    it "do_request should respond with valid p2p" do
      @opts.merge!({'p2p.preference' => 'enabled'})
      doc = @opentok.do_request("/session/create", @opts)
      doc.root.get_elements('Session')[0].get_elements('properties')[0].get_elements('p2p')[0].get_elements('preference')[0].children[0].to_s.should =='enabled'
    end
  end
  
  
  describe "Session creation" do
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

  describe "Token creation" do
    before :all do
      @opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret
      @valid_session = @opentok.create_session(@host).to_s
    end
    
    it "should be possible to create a token" do
      token = @opentok.generate_token :session_id => @valid_session.to_s
      
      token.should match(/\A[0-9A-z=]+\Z/)
    end

    it "should be able to set parameters in token" do
      token = @opentok.generate_token :session_id => @valid_session.to_s, :role=> OpenTok::RoleConstants::PUBLISHER, :connection_data => "username=Bob,level=4"

      str = token[4..token.length]
      decoded = Base64.decode64(str)

      decoded.should match(/publisher.*username.*Bob.*level.*4/)
    end
  end

  describe "Archive Download" do
    before :all do
      @opentok = OpenTok::OpenTokSDK.new @api_key, @api_secret
      @valid_session = @opentok.create_session(@host).to_s
    end
  end
end
