require 'spec_helper'

describe OpenTok do

  let(:api_key) { '459782' }
  let(:api_secret) { 'b44c3baa32b6476d9d88e8194d0eb1c6b777f76b' }
  let(:api_url) { 'https://api.opentok.com' }
  let(:host) { 'localhost' }

  let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret }

  describe "test Initializers" do
    it "should be backwards compatible if user set api URL with no effect" do
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret, {:api_url=>"bla bla"}
      opentok.api_url.should eq api_url
    end

    it "should set api URL with no options" do
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret
      opentok.api_url.should eq api_url
    end

    it "should be OpenTok SDK Object" do
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret
      opentok.should be_instance_of OpenTok::OpenTokSDK
    end
  end

  describe "Generate Sessions" do
    #use_vcr_cassette "session"

    let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret }

    it "should generate valid session" do
      session = opentok.create_session host
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end

    it "should generate valid session camelCase" do
      session = opentok.createSession host
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end

    it "should generate valid p2p session" do
      # Creating Session object with p2p enabled
      sessionProperties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}    # or disabled
      session = opentok.createSession( @location, sessionProperties )
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end
  end

  describe "invalid Sessions" do
    #use_vcr_cassette "invalidSession"
    it "should raise an exception with an invalid key and secret" do
      invalidOT = OpenTok::OpenTokSDK.new 0, ''

      expect{
        session = invalidOT.create_session host
      }.to raise_error OpenTok::OpenTokException
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
    it "should be able to set parameters in token" do
      token = opentok.generate_token :session_id => session, :role=> OpenTok::RoleConstants::PUBLISHER, :connection_data => "username=Bob,level=4"
      str = token[4..token.length]
      decoded = Base64.decode64(str)
      decoded.should match(/publisher.*username.*Bob.*level.*4/)
    end
  end


  describe "Archiving downloads" do
    #use_vcr_cassette "archives"
    let(:api_key) { '459782' }
    let(:api_secret) { 'b44c3baa32b6476d9d88e8194d0eb1c6b777f76b' }
    let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret, {:api_url=>""} }
    let(:opts) { {:partner_id => api_key, :location=>host} }

    let(:session) { '1_MX40NTk3ODJ-MTI3LjAuMC4xflR1ZSBTZXAgMDQgMTQ6NTM6MDIgUERUIDIwMTJ-MC41MjExODEzfg' }
    let(:token) { opentok.generateToken({:session_id => session, :role=>OpenTok::RoleConstants::MODERATOR}) }
    let(:archiveId) { "200567af-0726-4e93-883b-fe0426d6310a" }

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
      url = otArchive.downloadArchiveURL(vid, token)
      url.start_with?('http').should eq true
    end
  end

  describe "Delete Archives" do
    use_vcr_cassette "deleteArchive"
    let(:api_key) { '459782' }
    let(:api_secret) { 'b44c3baa32b6476d9d88e8194d0eb1c6b777f76b' }
    let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret, {:api_url=>""} }
    let(:session) { '1_MX40NTk3ODJ-MTI3LjAuMC4xflR1ZSBTZXAgMDQgMTQ6NTM6MDIgUERUIDIwMTJ-MC41MjExODEzfg' }
    let(:token) { opentok.generateToken({:session_id => session, :role=>OpenTok::RoleConstants::PUBLISHER}) }
    let(:archiveId) { "200567af-0726-4e93-883b-fe0426d6310a" }

    it "should return false on wrong moderator" do
      a = opentok.deleteArchive( archiveId, token )
      a.should eq false
    end
  end

  describe "stitch api" do
    use_vcr_cassette "stitchArchive"
    let(:api_key) { '459782' }
    let(:api_secret) { 'b44c3baa32b6476d9d88e8194d0eb1c6b777f76b' }
    let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret, {:api_url=>""} }
    let(:session) { '1_MX40NTk3ODJ-MTI3LjAuMC4xflR1ZSBTZXAgMDQgMTQ6NTM6MDIgUERUIDIwMTJ-MC41MjExODEzfg' }
    let(:token) { opentok.generateToken({:session_id => session, :role=>OpenTok::RoleConstants::MODERATOR}) }
    let(:archiveId) { "200567af-0726-4e93-883b-fe0426d6310a" }

    it "should return stich url" do
      a = opentok.stitchArchive( archiveId )
      a[:code].should == 201
      a[:location].start_with?('http').should eq true
    end
  end

end
