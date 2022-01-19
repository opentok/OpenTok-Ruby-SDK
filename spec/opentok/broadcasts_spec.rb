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
  let(:broadcast) { opentok.broadcasts }

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
    b = broadcast.find started_broadcast_id
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

  it "raise an error if layout options are empty" do
    expect {
      broadcast.layout(started_broadcast_id, {})
    }.to raise_error(ArgumentError)
  end

  it "raise an error if broadcast id is not provided" do
    expect {
      broadcast.layout("", {
          type: "custom",
          stylesheet: "the layout stylesheet (only used with type == custom)"
      })
    }.to raise_error(ArgumentError)
  end

  it "raise an error if custom type has no style sheet" do
    expect {
      broadcast.layout(started_broadcast_id, {
          type: "custom",
      })
    }.to raise_error(ArgumentError)
  end

  it "raise an error if non-custom type has style sheet" do
    expect {
      broadcast.layout(started_broadcast_id, {
          type: "pip",
          stylesheet: "the layout stylesheet (only used with type == custom)"
      })
    }.to raise_error(ArgumentError)
  end

  it "raise an error for non valid type" do
    expect {
      broadcast.layout(started_broadcast_id, {
          type: "not-valid",
          stylesheet: "stream {}"
      })
    }.to raise_error(ArgumentError)
  end

  it "change the layout to custom type with custom stylesheet" do
    stub_request(:put, "https://api.opentok.com/v2/project/#{api_key}/broadcast/#{started_broadcast_id}/layout").
      with(body: {type: 'custom', stylesheet: 'stream {float: left; height: 100%; width: 33.33%;}'}).
      to_return(status: 200)

    response  = broadcast.layout(started_broadcast_id, {
        type: "custom",
        stylesheet: "stream {float: left; height: 100%; width: 33.33%;}"
    })
    expect(response).not_to be_nil
  end

  it "raise an error if invalid layout type" do
    expect {
      broadcast.layout(started_broadcast_id, {
          type: "pip1"
      })
    }.to raise_error(ArgumentError)
  end

  it "raise an error if invalid layout type with screenshare_type" do
    expect {
      broadcast.layout(started_broadcast_id, {
          type: "pip",
          screenshare_type: "bestFit"
      })
    }.to raise_error(ArgumentError)
  end

  it "raise an error if invalid layout screenshare_type" do
    expect {
      broadcast.layout(started_broadcast_id, {
          type: "bestFit",
          screenshare_type: "pip1"
      })
    }.to raise_error(ArgumentError)
  end

  it "calls layout on broadcast object", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" } } do
    b = broadcast.find started_broadcast_id
    expect(b).to be_an_instance_of OpenTok::Broadcast
    expect(b.id).to eq started_broadcast_id
    expect {
      b.layout(
          :type => 'pip1',
          )
    }.to raise_error(ArgumentError)
  end

  it "changes the layout of a broadcast", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" } } do
    stub_request(:put, "https://api.opentok.com/v2/project/#{api_key}/broadcast/#{started_broadcast_id}/layout").
      to_return(status: 200)

    response = broadcast.layout(started_broadcast_id, {
        :type => "verticalPresentation"
    })
    expect(response).not_to be_nil
  end

  it "changes the screenshare option in the layout of a broadcast", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" } } do
    stub_request(:put, "https://api.opentok.com/v2/project/#{api_key}/broadcast/#{started_broadcast_id}/layout").
      to_return(status: 200)

    response = broadcast.layout(started_broadcast_id, {
        :type => "bestFit",
        :screenshare_type => "bestFit"
    })
    expect(response).not_to be_nil
  end

  it "adds a stream to a broadcast", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" } } do
    opts = {}
    response = broadcast.add_stream(started_broadcast_id, '12312312-3811-4726-b508-e41a0f96c68f', opts)
    expect(response.code).to eq(204)
  end

  it "removes a stream from a broadcast", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" } } do
    response = broadcast.remove_stream(started_broadcast_id, '12312312-3811-4726-b508-e41a0f96c68f')
    expect(response.code).to eq(204)
  end

  xcontext "for many broadcasts" do
    it "should return all broadcasts", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      broadcast_list = broadcasts.all
      expect(broadcast_list).to be_an_instance_of OpenTok::BroadcastList
      expect(broadcast_list.total).to eq 6
      expect(broadcast_list.count).to eq 6
    end

    it "should return broadcasts with an offset", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      broadcast_list = broadcasts.all :offset => 3
      expect(broadcast_list).to be_an_instance_of OpenTok::BroadcastList
      expect(broadcast_list.total).to eq 3
      expect(broadcast_list.count).to eq 3
    end

    it "should return count number of broadcasts", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      broadcast_list = broadcasts.all :count => 2
      expect(broadcast_list).to be_an_instance_of OpenTok::BroadcastList
      expect(broadcast_list.count).to eq 2
      expect(broadcast_list.count).to eq 2
    end

    it "should return part of the broadcasts when using offset and count", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      broadcast_list = broadcasts.all :count => 4, :offset => 2
      expect(broadcast_list).to be_an_instance_of OpenTok::BroadcastList
      expect(broadcast_list.count).to eq 4
      expect(broadcast_list.count).to eq 4
    end

    it "should return session broadcasts", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      broadcast_list = broadcasts.all :sessionId => session_id
      expect(broadcast_list).to be_an_instance_of OpenTok::BroadcastList
      expect(broadcast_list.total).to eq 3
      expect(broadcast_list.count).to eq 3
    end
  end
end
