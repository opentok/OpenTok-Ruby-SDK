require "opentok/opentok"
require "opentok/sip"
require "opentok/version"
require "spec_helper"

describe OpenTok::Sip do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:connection_id) { "CONNID" }
  let(:expiring_token) { "TOKENID" }
  let(:sip_uri) { "sip:+15128675309@acme.pstn.example.com;transport=tls" }
  let(:sip_username) { "bob" }
  let(:sip_password) { "abc123" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:sip) { opentok.sip }
  let(:valid_dtmf_digits) { "0123456789*#p" }
  let(:invalid_dtmf_digits) { "0123456789*#pabc" }
  subject { sip }

  it "receives a valid response", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    opts = { "auth" => { "username" => sip_username,
                         "password" => sip_password },
             "secure" => "true",
             "video" => "true"
    }
    response = sip.dial(session_id, expiring_token, sip_uri, opts)
    expect(response).not_to be_nil
  end

  describe "#play_dtmf_to_connection" do
    it "raises an ArgumentError when passed an invalid dtmf digit string" do
      expect {
        sip.play_dtmf_to_connection(session_id, connection_id, invalid_dtmf_digits)
      }.to raise_error(ArgumentError)
    end

    it "returns a 200 response code when passed a valid dtmf digit string", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      response = sip.play_dtmf_to_connection(session_id, connection_id, valid_dtmf_digits)
      expect(response.code).to eq(200)
    end
  end

  describe "#play_dtmf_to_session" do
    it "raises an ArgumentError when passed an invalid dtmf digit string" do
      expect {
        sip.play_dtmf_to_session(session_id, invalid_dtmf_digits)
      }.to raise_error(ArgumentError)
    end

    it "returns a 200 response code when passed a valid dtmf digit string", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      response = sip.play_dtmf_to_session(session_id, valid_dtmf_digits)
      expect(response.code).to eq(200)
    end
  end
end
