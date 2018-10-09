require "opentok/signals"
require "opentok/opentok"
require "opentok/version"
require "spec_helper"

describe OpenTok::Signals do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:connection_id) { "CONNID" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:signal) { opentok.signals }

  subject { signal }

  it 'raise an error on nil sessionId' do
    expect {
      signal.send(nil)
    }.to raise_error(ArgumentError)
  end

  it 'raise an error on empty sessionId' do
    expect {
      signal.send('')
    }.to raise_error(ArgumentError)
  end

  it "receives a valid response for all connections", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    opts = { "type" => "chat",
             "data" => "Hello",
    }
    response = signal.send(session_id, "", opts)
    expect(response).not_to be_nil
  end

  it "receives a valid response for a connection", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    opts = { "type" => "chat",
             "data" => "Hello",
    }
    response = signal.send(session_id, connection_id, opts)
    expect(response).not_to be_nil
  end


end