require "opentok/session"

require "spec_helper"
require "shared/session_generates_tokens"

describe OpenTok::Session do

  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }

  let(:session) { OpenTok::Session.new api_key, api_secret, session_id }
  subject { session }

  context "when initialized with no options" do
    it { should be_an_instance_of OpenTok::Session }
    it "should have an api_key property" do
      expect(session.api_key).to eq api_key
    end
    it "should have an api_secret property" do
      expect(session.api_secret).to eq api_secret
    end
    it "should have a session_id property" do
      expect(session.session_id).to eq session_id
    end
    it "should be represented by session_id when coerced to a string" do
      expect(session.to_s).to eq session_id
    end
    it "should have the default media mode of relayed" do
      expect(session.media_mode).to eq :relayed
    end
    it "should not have a location value" do
      expect(session.location).to eq nil
    end
    include_examples "session generates tokens"
  end

  context "when initialized with options" do
    let(:default_opts) { {} }
    let(:session) { OpenTok::Session.new api_key, api_secret, session_id, default_opts }

    it { should be_an_instance_of OpenTok::Session }
    it "should have an api_key property" do
      expect(session.api_key).to eq api_key
    end
    it "should have an api_secret property" do
      expect(session.api_secret).to eq api_secret
    end
    it "should have a session_id property" do
      expect(session.session_id).to eq session_id
    end
    it "should be represented by session_id when coerced to a string" do
      expect(session.to_s).to eq session_id
    end
    it "should have media mode when set in options" do
      opts = { :media_mode => :routed }
      session = OpenTok::Session.new api_key, api_secret, session_id, opts
      expect(session.media_mode).to eq :routed
      opts = { :media_mode => :relayed }
      session = OpenTok::Session.new api_key, api_secret, session_id, opts
      expect(session.media_mode).to eq :relayed
    end
    it "should have a location value when set in options" do
      opts = { :location => '12.34.56.78' }
      session = OpenTok::Session.new api_key, api_secret, session_id, opts
      expect(session.location).to eq opts[:location]
    end
    include_examples "session generates tokens"
  end

end
