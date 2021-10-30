require "opentok/opentok"
require "opentok/version"
require "opentok/connections"
require "spec_helper"

describe OpenTok::Connections do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:connection_id) { "CONNID" }
  let(:stream_id) { "STREAMID" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:connection) { opentok.connections }

  subject { connection }


  it 'raise an error on nil session_id' do
    expect {
      connection.forceDisconnect(nil,connection_id)
    }.to raise_error(ArgumentError)
  end

  it 'raise an error on nil connection_id' do
    expect {
      connection.forceDisconnect(session_id,nil)
    }.to raise_error(ArgumentError)
  end

  it "forces a connection to be terminated", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = connection.forceDisconnect(session_id, connection_id)
    expect(response).not_to be_nil
  end

  it "forces the specified stream to be muted", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = connection.force_mute_stream(session_id, stream_id)
    expect(response.code).to eq(200)
  end

  it "forces all streams in a session to be muted", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = connection.force_mute_session(session_id)
    expect(response.code).to eq(200)
  end

  it "forces all current streams in a session and future streams joining the session to be muted", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = connection.force_mute_session(session_id, { "active" => "true" })
    expect(response.code).to eq(200)
  end

  it "forces all current streams in a session to be muted except for the specified excluded streams", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = connection.force_mute_session(session_id, { "excludedStreams" => ["b1963d15-537f-459a-be89-e00fc310b82b"] })
    expect(response.code).to eq(200)
  end
end
