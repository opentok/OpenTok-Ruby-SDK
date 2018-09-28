require "opentok/broadcast"
require "opentok/broadcasts"
require "opentok/opentok"
require "opentok/version"
require "spec_helper"

describe OpenTok::Broadcasts do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:broadcast_id) { "BROADCASTID" }
  let(:started_broadcast_id) { "13dbcc23-af92-4862-9184-74b21815a814" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:broadcast) { opentok.broadcast}

  subject { broadcast }

  it 'raise an error on empty sessionId' do
    opts = {
        :outputs => {
            :hls => {}
        }
    }
    expect {
      broadcast.create('', opts)
    }.to raise_error(ArgumentError)
  end
  it 'raise an error on nil sessionId' do
    opts = {
        :outputs => {
            :hls => {}
        }
    }
    expect {
      broadcast.create(nil, opts)
    }.to raise_error(ArgumentError)
  end
  it 'raise an error on empty options' do
    expect {
      broadcast.create(nil, {})
    }.to raise_error(ArgumentError)
  end
  it 'fetches a hls broadcast url', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    opts = {
        :outputs => {
            :hls => {}
        }
    }
    b_hls = broadcast.create(session_id, opts)
    expect(b_hls).to be_an_instance_of OpenTok::Broadcast
    expect(b_hls.id).to eq broadcast_id
    expect(b_hls.broadcastUrls['hls']).to eq "https://cdn-broadcast001-pdx.tokbox.com/14787/14787_b930bf08-1c9f-4c55-ab04-7d192578c057.smil/playlist.m3u8"
  end

  it 'starts a rtmp broadcast', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    opts = {
        :outputs => {
            :hls => {},
            :rtmp => [
                {
                    :id => "rubyTestStream",
                    :serverUrl => "rtmp://x.rtmp.youtube.com/live2",
                    :streamName => "66c9-jwuh-pquf-9x18"
                }
            ]
        }
    }
    b_rtmp = broadcast.create(session_id, opts)
    expect(b_rtmp).to be_an_instance_of OpenTok::Broadcast
    expect(b_rtmp.id).to eq broadcast_id
    expect(b_rtmp.broadcastUrls["rtmp"][0]["serverUrl"]).to eq "rtmp://x.rtmp.youtube.com/live2"
    expect(b_rtmp.broadcastUrls["rtmp"].count).to eq 1
  end

  it 'finds a broadcast', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    b = broadcast.find(started_broadcast_id)
    expect(b).to be_an_instance_of OpenTok::Broadcast
    expect(b.id).to eq started_broadcast_id
    expect(b.broadcastUrls["rtmp"][0]["serverUrl"]).to eq "rtmp://x.rtmp.youtube.com/live2"
    expect(b.broadcastUrls["rtmp"].count).to eq 1
  end
  it 'raise an error on empty broadcastId in find' do
    expect {
      broadcast.find("")
    }.to raise_error(ArgumentError)
  end
  it 'raise an error on nil broadcastId in find' do
    expect {
      broadcast.find(nil)
    }.to raise_error(ArgumentError)
  end
  it 'raise an error on empty broadcastId stop' do
    expect {
      broadcast.stop("")
    }.to raise_error(ArgumentError)
  end
  it 'raise an error on nil broadcastId stop' do
    expect {
      broadcast.stop(nil)
    }.to raise_error(ArgumentError)
  end
  it 'stops a broadcast', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    b = broadcast.stop(started_broadcast_id)
    expect(b).to be_an_instance_of OpenTok::Broadcast
    expect(b.id).to eq started_broadcast_id
    expect(b.broadcastUrls).to be_nil
    expect(b.status).to eq "stopped"
  end
end