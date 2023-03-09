require "opentok/opentok"
require "opentok/websocket"
require "opentok/version"
require "spec_helper"

describe OpenTok::WebSocket do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:connection_id) { "CONNID" }
  let(:expiring_token) { "TOKENID" }
  let(:websocket_uri) { "ws://service.com/wsendpoint" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:websocket) { opentok.websocket }
  subject { websocket }

  it "receives a valid response", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = websocket.connect(session_id, expiring_token, websocket_uri)
    expect(response).not_to be_nil
  end
end
