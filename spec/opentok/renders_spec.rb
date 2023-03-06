require "opentok/render"
require "opentok/renders"
require "opentok/opentok"
require "opentok/version"
require "spec_helper"

describe OpenTok::Renders do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:render_id) { "80abaf0d-25a3-4efc-968f-6268d620668d" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:token) { "TOKEN" }
  let(:render) { opentok.renders }
  let(:render_url) { 'https://example.com/my-render'}

  subject { render }

  it 'raises an error on empty sessionId' do
    opts = {
        :token => token,
        :url => render_url
    }
    expect {
      render.start('', opts)
    }.to raise_error(ArgumentError)
  end

  it 'raises an error on nil sessionId' do
    opts = {
      :token => token,
      :url => render_url
    }
    expect {
      render.start(nil, opts)
    }.to raise_error(ArgumentError)
  end

  it 'raises an error on empty options' do
    expect {
      render.start(session_id, {})
    }.to raise_error(ArgumentError)
  end

  it 'raises an error if token is not set in options' do
    opts = { :url => render_url }
    expect { render.start(session_id, opts) }.to raise_error(ArgumentError)
  end
  
  it 'raises an error if url is not set in options' do
    opts = { :token => token }
    expect { render.start(session_id, opts) }.to raise_error(ArgumentError)
  end

  it 'starts an Experience Composer render', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    opts = {
      :token => token,
      :url => render_url
    }
    r = render.start(session_id, opts)
    expect(r).to be_an_instance_of OpenTok::Render
    expect(r.sessionId).to eq session_id
    expect(r.url).to eq render_url
    expect(r.status).to eq "starting"
  end

  it 'raises an error on empty renderId in find' do
    expect {
      render.find("")
    }.to raise_error(ArgumentError)
  end

  it 'raises an error on nil renderId in find' do
    expect {
      render.find(nil)
    }.to raise_error(ArgumentError)
  end

  it 'finds an Experience Composer render', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    r = render.find render_id
    expect(r).to be_an_instance_of OpenTok::Render
    expect(r.id).to eq render_id
  end

  it 'raises an error on empty renderId in stop' do
    expect {
      render.stop("")
    }.to raise_error(ArgumentError)
  end

  it 'raises an error on nil renderId in stop' do
    expect {
      render.stop(nil)
    }.to raise_error(ArgumentError)
  end

  it 'stops an Experience Composer render', :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    r = render.stop(render_id)
    expect(r).to be_an_instance_of OpenTok::Render
  end

  context "for many renders" do
    it 'raises an error for an invalid limit in list' do
      expect {
        render.list(count: 1001)
      }.to raise_error(ArgumentError)
    end

    it "should return all renders", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      render_list = render.list
      expect(render_list).to be_an_instance_of OpenTok::RenderList
      expect(render_list.count).to eq 6
      expect(render_list.total).to eq 6
    end

    it "should return renders with an offset", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      render_list = render.list :offset => 3
      expect(render_list).to be_an_instance_of OpenTok::RenderList
      expect(render_list.count).to eq 3
      expect(render_list.total).to eq 3
    end

    it "should return count number of renders", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      render_list = render.list :count => 2
      expect(render_list).to be_an_instance_of OpenTok::RenderList
      expect(render_list.count).to eq 2
      expect(render_list.total).to eq 2
    end

    it "should return part of the renders when using offset and count", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      render_list = render.list :count => 2, :offset => 2
      expect(render_list).to be_an_instance_of OpenTok::RenderList
      expect(render_list.count).to eq 2
      expect(render_list.total).to eq 2
    end
  end
end
