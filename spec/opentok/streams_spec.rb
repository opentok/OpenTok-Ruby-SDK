require 'opentok/opentok'
require 'opentok/version'
require 'opentok/streams'
require 'opentok/stream'
require 'opentok/stream_list'

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
      streams.all(nil)
    }.to raise_error(ArgumentError)
  end
  it 'raise an error on empty session_id' do
    expect {
      streams.all('')
    }.to raise_error(ArgumentError)
  end
  it 'get all streams information', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    all_streams = streams.all(session_id)
    expect(all_streams).to be_an_instance_of OpenTok::StreamList
    expect(all_streams.total).to eq 2
    expect(all_streams[0].layoutClassList[1]).to eq "focus"
  end
  it 'get specific stream information', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    stream = streams.find(session_id, stream_id)
    expect(stream).to be_an_instance_of OpenTok::Stream
    expect(stream.videoType).to eq 'camera'
    expect(stream.layoutClassList.count).to eq 1
    expect(stream.layoutClassList.first).to eq "full"
    expect(stream.id).not_to be_nil
  end
  it 'layout raises an error on empty session_id' do
    expect {
      streams.layout('', {} )
    }.to raise_error(ArgumentError)
  end
  it 'layout raises an error on an empty stream list' do
    expect {
      streams.layout(session_id, {})
    }.to raise_error(ArgumentError)
  end
  it 'layout working on two stream list', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} }  do
    streams_list = {
        :items => [
            {
                :id => "8b732909-0a06-46a2-8ea8-074e64d43422",
                :layoutClassList => ["full"]
            },
            {
                :id => "8b732909-0a06-46a2-8ea8-074e64d43423",
                :layoutClassList => ["full", "focus"]
            }
        ]
    }
    response = streams.layout(session_id, streams_list)
    expect(response).not_to be_nil
  end
end