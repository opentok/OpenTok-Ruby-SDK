require "opentok/session"

require "spec_helper"
require "shared/session_generates_tokens"

describe OpenTok::Session do

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
    it "should not have the default p2p value of false" do
      expect(session.p2p).to eq false
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
    it "should have p2p value when set in options" do
      opts = { :p2p => true }
      session = OpenTok::Session.new api_key, api_secret, session_id, opts
      expect(session.p2p).to eq true
      opts = { :p2p => false }
      session = OpenTok::Session.new api_key, api_secret, session_id, opts
      expect(session.p2p).to eq false
    end
    it "should have a location value when set in options" do
      opts = { :location => '12.34.56.78' }
      session = OpenTok::Session.new api_key, api_secret, session_id, opts
      expect(session.location).to eq opts[:location]
    end
    include_examples "session generates tokens"
  end

end
