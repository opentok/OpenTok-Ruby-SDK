require 'spec_helper'

describe "Functionality Test" do

  let(:api_key) { '459782' }
  let(:api_secret) { 'b44c3baa32b6476d9d88e8194d0eb1c6b777f76b' }
  let(:host) { '127.0.0.1' }
  let(:api_staging_url) { 'https://staging.tokbox.com/hl' }
  let(:api_production_url) { 'https://api.opentok.com/hl' }

  describe "test Initializers" do
    it "should set staging URL with no options" do
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret
      opentok.api_url.should eq api_staging_url
    end

    it "should be possible to set the api url as an option" do
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret, :api_url => api_production_url
      opentok.api_url.should eq api_production_url
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret, :api_url => api_staging_url
      opentok.api_url.should eq api_staging_url
    end

    it "should set staging URL with option false" do
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret, false
      opentok.api_url.should eq api_staging_url
    end

    it "should set production URL with option true" do
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret, true
      opentok.api_url.should eq api_production_url
    end
  end

  describe "Generate Sessions" do
    let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret }

    it "should generate valid session" do
      session = opentok.create_session host
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end

    it "should generate valid session camelCase" do
      session = opentok.createSession host
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end
  end

  describe "Generate Tokens" do

    let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret }
    let(:session) { opentok.createSession host }

    it "should generate valid token" do
      token = opentok.generate_token({:session_id => session, :role=>OpenTok::RoleConstants::MODERATOR})
      token.should match(/(T1==)+[0-9A-z_]+/)
    end

    it "should generate valid token camelCase" do
      token = opentok.generateToken({:session_id => session, :role=>OpenTok::RoleConstants::MODERATOR})
      token.should match(/(T1==)+[0-9A-z_]+/)
    end
  end

end

describe OpenTok do

  let(:api_key) { '459782' }
  let(:api_secret) { 'b44c3baa32b6476d9d88e8194d0eb1c6b777f76b' }
  let(:api_staging_url) { 'https://staging.tokbox.com/hl' }
  let(:api_production_url) { 'https://api.opentok.com/hl' }
  let(:host) { 'localhost' }

  let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret }

  describe "Production Environment" do

    let(:api_key) { '11421872' }
    let(:api_secret) { '296cebc2fc4104cd348016667ffa2a3909ec636f' }
    let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret, {:api_url=>api_production_url} }
    let(:opts) { {:partner_id => api_key, :location=>host} }

    it "should be possible to valid a OpenTokSDK object with a valid key and secret" do
      opentok.should be_instance_of OpenTok::OpenTokSDK
    end

    it "a new OpenTokSDK object should point to the staging environment by default" do
      opentok.api_url.should eq api_production_url
    end

    describe "Archiving downloads" do

      let(:session) { '1_MX4xNDk3MTI5Mn5-MjAxMi0wNS0yMCAwMTowMzozMS41MDEzMDArMDA6MDB-MC40NjI0MjI4MjU1MDF-' }
      let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret, {:api_url=>api_production_url} }
      let(:token) { opentok.generateToken({:session_id => session, :role=>OpenTok::RoleConstants::MODERATOR}) }
      let(:archiveId) { '5f74aee5-ab3f-421b-b124-ed2a698ee939' }

      it "should have archive resources" do
        otArchive = opentok.getArchiveManifest(archiveId, token)
        otArchiveResource = otArchive.resources[0]
        vid = otArchiveResource.getId()
        vid.should match(/[0-9A-z=]+/)
      end

      it "should return download url" do
        otArchive = opentok.get_archive_manifest(archiveId, token)
        otArchiveResource = otArchive.resources[0]
        vid = otArchiveResource.getId()
        url = otArchive.downloadArchiveURL(vid)
        url.start_with?('http').should eq true
      end

      it "should return file url" do
        otArchive = opentok.get_archive_manifest(archiveId, token)
        otArchiveResource = otArchive.resources[0]
        vid = otArchiveResource.getId()
        url = otArchive.downloadArchiveURL(vid, token)
        url.start_with?('http').should eq true
      end
    end
  end


  describe "Session creation" do
    it "should raise an exception with an invalid key and secret" do
      opentok = OpenTok::OpenTokSDK.new 0, ''

      expect{
        session = opentok.create_session host
      }.to raise_error OpenTok::OpenTokException
    end

  end

  describe "Token creation" do

    let(:valid_session) { opentok.create_session(host).to_s }

    it "should be possible to create a token" do
      token = opentok.generate_token :session_id => valid_session

      token.should match(/\A[0-9A-z=]+\Z/)
    end

    it "should be able to set parameters in token" do
      token = opentok.generate_token :session_id => valid_session, :role=> OpenTok::RoleConstants::PUBLISHER, :connection_data => "username=Bob,level=4"

      str = token[4..token.length]
      decoded = Base64.decode64(str)

      decoded.should match(/publisher.*username.*Bob.*level.*4/)
    end
  end

  describe "Archive Download" do

    let(:valid_session) { opentok.create_session(host).to_s }

#    it "If token does not have moderator role, raise error" do
#      token = opentok.generate_token(:session_id=>valid_session)
#      expect{
#        opentok.get_archive_manifest("", token)
#      }.to raise_error OpenTok::OpenTokException
#    end
  end
end
