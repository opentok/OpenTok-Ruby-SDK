require "opentok/signals"
require "opentok/opentok"
require 'rspec'

describe OpenTok::Signals do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:signals) { opentok.signals}

  it "receives a valid response for all connections", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    opts = { "type" => "chat",
             "data" => "Hello signal",
    }

    response = signals.send(session_id, opts)
    expect(response).not_to be_nil
  end

  it 'send a signal to a specific connection id' do

  end
end