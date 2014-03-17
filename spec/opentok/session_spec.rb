require "opentok/session"

require "spec_helper"

describe OpenTok::Session do

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "1_MX4xMjM0NTZ-flNhdCBNYXIgMTUgMTQ6NDI6MjMgUERUIDIwMTR-MC40OTAxMzAyNX4" }

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
    it "should not have a p2p value" do
      expect(session.p2p).to eq nil
    end
    it "should not have a location value" do
      expect(session.location).to eq nil
    end
    it "should be represented by session_id when coerced to a string" do
      expect(session.to_s).to eq session_id
    end
  end

end
