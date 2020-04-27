require "opentok/opentok"
require "opentok/version"

require "spec_helper"
require "shared/opentok_generates_tokens"

describe OpenTok::Client do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:api_url) { "https://api.opentok.com" }


  let(:client) { OpenTok::Client.new api_key, api_secret, api_url }
  subject { client }

  context "when initialized with no options" do
    it { should be_an_instance_of OpenTok::Client }

    it "should have an api_key property" do
      expect(client.api_key).to eq api_key
    end

    it "should have an api_secret property" do
      expect(client.api_secret).to eq api_secret
    end

    it "should be able to access HTTParty open_timeout method" do
      expect(OpenTok::Client).to respond_to(:open_timeout)
    end

    it 'should have a default timeout_length property of 2 seconds' do
      expect(client.timeout_length).to eq 2
    end
  end

  context "when initialized with timeout_length custom option" do
    let(:client) { OpenTok::Client.new api_key, api_secret, api_url, ua_addendum='', :timeout_length => timeout_length }
    let(:timeout_length) { 10 }

    it { should be_an_instance_of(OpenTok::Client) }

    it "should override timeout_length default with custom integer" do
      expect(client.timeout_length).to eq 10
    end
  end
end