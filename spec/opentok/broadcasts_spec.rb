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
  # it 'starts a rtmp broadcast', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
  #   opts = {
  #       :outputs => {
  #           :hls => {}
  #       }
  #   }
  #   b_hls = broadcast.create(session_id, opts)
  #   expect(b_hls).to be_an_instance_of OpenTok::Broadcast
  #   expect(b_hls.id).to eq broadcast_id
  #   expect(b_hls.broadcastUrls['hls']).to eq "https://cdn-broadcast001-pdx.tokbox.com/14787/14787_b930bf08-1c9f-4c55-ab04-7d192578c057.smil/playlist.m3u8"
  # end


end