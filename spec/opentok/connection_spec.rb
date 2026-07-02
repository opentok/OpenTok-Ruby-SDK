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
  let(:connections) { opentok.connections }

  subject { connections }


  it 'raises an error on nil session_id when attempting to force disconnect' do
    expect {
      connections.forceDisconnect(nil,connection_id)
    }.to raise_error(ArgumentError)
  end

  it 'raises an error on nil connection_id when attempting to force disconnect' do
    expect {
      connections.forceDisconnect(session_id,nil)
    }.to raise_error(ArgumentError)
  end

  it "forces a connection to be terminated", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = connections.forceDisconnect(session_id, connection_id)
    expect(response).not_to be_nil
  end

  context "when attempting to list connections" do
    it 'raises an error on nil session_id' do
      expect {
        connections.list(nil)
      }.to raise_error(ArgumentError)
    end

    it 'raises an error with count too low' do
      expect {
        connections.list(session_id, :count => 0)
      }.to raise_error(ArgumentError)
    end

    it 'raises an error with count too high' do
      expect {
        connections.list(session_id, :count => 1001)
      }.to raise_error(ArgumentError)
    end

    it "should return all connections", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      connections_list = connections.list(session_id)
      expect(connections_list).to be_an_instance_of OpenTok::ConnectionList
      expect(connections_list.total).to eq 5
      expect(connections_list.count).to eq 5
    end

    it "should return connections with an offset", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      connections_list = connections.list(session_id, :offset => 2)
      expect(connections_list).to be_an_instance_of OpenTok::ConnectionList
      expect(connections_list.total).to eq 3
      expect(connections_list.count).to eq 3
    end

    it "should return count number of connections", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      connections_list = connections.list(session_id, :count => 2)
      expect(connections_list).to be_an_instance_of OpenTok::ConnectionList
      expect(connections_list.total).to eq 2
      expect(connections_list.count).to eq 2
    end

    it "should return part of the connections when using offset and count", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
      connections_list = connections.list(session_id, :offset => 1, :count => 2)
      expect(connections_list).to be_an_instance_of OpenTok::ConnectionList
      expect(connections_list.total).to eq 2
      expect(connections_list.count).to eq 2
    end
  end
end
