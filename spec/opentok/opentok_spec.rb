require "spec_helper"
require "opentok/opentok"
require "opentok/version"
require "shared/generates_tokens"

describe OpenTok::OpenTok do

  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  subject { opentok }

  context "when initialized properly" do

    let(:api_key) { "123456" }
    let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }

    # let(:api_key) { "854511" }
    # let(:api_secret) { "93936990b97ffede04378028766bdc1755562cce" }

    let(:default_api_url) { "https://api.opentok.com" }

    it { should be_an_instance_of(OpenTok::OpenTok) }

    it "should have an api_key property" do
      expect(opentok.api_key).to eq api_key
    end

    it "has the default api_url set" do
      expect(opentok.api_url).to eq default_api_url
    end

    include_examples "generates tokens"

    describe "#create_session" do

      it "creates default sessions", :vcr => { :erb => { :version => OpenTok::VERSION } } do
        session = opentok.create_session
        expect(session).to be_an_instance_of OpenTok::Session
      end

      it "creates sessions with p2p enabled", :vcr => { :erb => { :version => OpenTok::VERSION } } do
        session = opentok.create_session :p2p => true
        expect(session).to be_an_instance_of OpenTok::Session
      end

      it "creates sessions with p2p disabled", :vcr => { :erb => { :version => OpenTok::VERSION } } do
        session = opentok.create_session :p2p => false
        expect(session).to be_an_instance_of OpenTok::Session
      end

      it "creates sessions with a location hint", :vcr => { :erb => { :version => OpenTok::VERSION } } do 
        session = opentok.create_session :location => '12.34.56.78'
        expect(session).to be_an_instance_of OpenTok::Session
      end

      it "creates sessions with p2p enabled and a location hint", :vcr => { :erb => { :version => OpenTok::VERSION } } do 
        session = opentok.create_session :p2p => true, :location => '12.34.56.78'
        expect(session).to be_an_instance_of OpenTok::Session
      end

      it "creates sessions with p2p disabled and a location hint", :vcr => { :erb => { :version => OpenTok::VERSION } } do 
        session = opentok.create_session :p2p => false, :location => '12.34.56.78'
        expect(session).to be_an_instance_of OpenTok::Session
      end

    end

    context "with an api_key that's a number" do
      let(:api_key) { 123456 }

      it { should be_an_instance_of(OpenTok::OpenTok) }

      it "changes api_key property to string" do
        expect(opentok.api_key).to eq api_key.to_s
      end

      it "should have an api_url property" do
        expect(opentok.api_url).to eq default_api_url
      end

      # TODO: maybe i don't need to run all the tests
      include_examples "generates tokens"
    end

    context "with an additional api_url" do
      let(:api_url) { "http://example.opentok.com" }
      let(:opentok) { OpenTok::OpenTok.new api_key, api_secret, api_url }

      it { should be_an_instance_of(OpenTok::OpenTok) }

      it "should have an api_url property" do
        expect(opentok.api_url).to eq api_url
      end

      # TODO: i don't need to run all the tests, but a set that checks for the URL's effect
      # include_examples "generates tokens"
    end

  end

  # ah, the magic of duck typing. the errors raised don't have any specific description
  # see discussion here: https://www.ruby-forum.com/topic/194593
  context "when initialized improperly" do
    context "with no arguments" do
      subject { -> { @opentok = OpenTOk::OpenTok.new } }
      it { should raise_error }
    end
    context "with just an api_key" do
      subject { -> { @opentok = OpenTOk::OpenTok.new "123456" } }
      it { should raise_error }
    end
    context "with arguments of the wrong type" do
      subject { -> { @opentok = OpenTOk::OpenTok.new api_key: "123456" } }
      it { should raise_error }
    end
  end

end
