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
end