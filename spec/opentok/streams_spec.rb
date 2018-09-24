require 'opentok/opentok'
require 'opentok/version'
require 'opentok/streams'
require 'opentok/stream'

require 'spec_helper'

describe OpenTok::Streams do
  before(:each) do
    now = Time.parse('2017-04-18 20:17:40 +1000')
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { '123456' }
  let(:api_secret) { '1234567890abcdef1234567890abcdef1234567890' }
  let(:session_id) { 'SESSIONID' }
  let(:stream_id) { 'STREAMID' }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:streams) { opentok.streams}

  subject { streams }

  it { should be_an_instance_of OpenTok::Streams }
  it 'raise an error on nil session_id' do
    expect {
      streams.info_stream(nil)
    }.to raise_error(ArgumentError)
  end
  it 'raise an error on empty session_id' do
    expect {
      streams.info_stream('')
    }.to raise_error(ArgumentError)
  end
  it 'get all streams information', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = streams.info_stream(session_id)
    expect(response).not_to be_nil
  end
  it 'get specific stream information', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    stream = streams.info_stream(session_id, stream_id)
    expect(stream).to be_an_instance_of OpenTok::Stream
    expect(stream.videoType).to eq 'camera'
    expect(stream.id).not_to be_nil
  end
end