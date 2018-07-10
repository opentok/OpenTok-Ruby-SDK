require "opentok/opentok"
require "opentok/version"

require "spec_helper"
require "shared/opentok_generates_tokens"

describe OpenTok::OpenTok do

  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  subject { opentok }

  context "when initialized properly" do

    let(:api_key) { "123456" }
    let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }

    let(:default_api_url) { "https://api.opentok.com" }

    it { should be_an_instance_of OpenTok::OpenTok  }

    it "should have an api_key property" do
      expect(opentok.api_key).to eq api_key
    end

    it "has the default api_url set" do
      expect(opentok.api_url).to eq default_api_url
    end

    include_examples "opentok generates tokens"

    describe "#create_session" do

      let(:location) { '12.34.56.78' }

      it "creates default sessions", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" } } do
        session = opentok.create_session
        expect(session).to be_an_instance_of OpenTok::Session
        # TODO: do we need to be any more specific about what a valid session_id looks like?
        expect(session.session_id).to be_an_instance_of String
        expect(session.media_mode).to eq :relayed
        expect(session.location).to eq nil
      end

      it "creates relayed media sessions", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
        session = opentok.create_session :media_mode => :relayed
        expect(session).to be_an_instance_of OpenTok::Session
        expect(session.session_id).to be_an_instance_of String
        expect(session.media_mode).to eq :relayed
        expect(session.location).to eq nil
      end

      it "creates routed media sessions", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
        session = opentok.create_session :media_mode => :routed
        expect(session).to be_an_instance_of OpenTok::Session
        expect(session.session_id).to be_an_instance_of String
        expect(session.media_mode).to eq :routed
        expect(session.location).to eq nil
      end

      it "creates sessions with a location hint", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
        session = opentok.create_session :location => location
        expect(session).to be_an_instance_of OpenTok::Session
        expect(session.session_id).to be_an_instance_of String
        expect(session.media_mode).to eq :relayed
        expect(session.location).to eq location
      end

      it "creates relayed media sessions with a location hint", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
        session = opentok.create_session :media_mode => :relayed, :location => location
        expect(session).to be_an_instance_of OpenTok::Session
        expect(session.session_id).to be_an_instance_of String
        expect(session.media_mode).to eq :relayed
        expect(session.location).to eq location
      end

      it "creates routed media sessions with a location hint", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
        session = opentok.create_session :media_mode => :routed, :location => location
        expect(session).to be_an_instance_of OpenTok::Session
        expect(session.session_id).to be_an_instance_of String
        expect(session.media_mode).to eq :routed
        expect(session.location).to eq location
      end

      it "creates relayed media sessions for invalid media modes", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
        session = opentok.create_session :media_mode => :blah
        expect(session).to be_an_instance_of OpenTok::Session
        expect(session.session_id).to be_an_instance_of String
        expect(session.media_mode).to eq :relayed
        expect(session.location).to eq nil
      end
      it "creates always archived sessions", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
        session = opentok.create_session :media_mode => :routed, :archive_mode => :always
        expect(session).to be_an_instance_of OpenTok::Session
        expect(session.session_id).to be_an_instance_of String
        expect(session.archive_mode).to eq :always
        expect(session.location).to eq nil
      end

      context "with relayed media mode and always archive mode" do
        subject { -> { session = opentok.create_session :archive_mode => :always, :media_mode => :relayed }}
        it { should raise_error }
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
      include_examples "opentok generates tokens"
    end

    context "with an additional api_url" do
      let(:api_url) { "http://example.opentok.com" }
      let(:opentok) { OpenTok::OpenTok.new api_key, api_secret, :api_url => api_url }

      it { should be_an_instance_of(OpenTok::OpenTok) }

      it "should have an api_url property" do
        expect(opentok.api_url).to eq api_url
      end

      # TODO: i don't need to run all the tests, just a set that checks for the URL's effect
      # include_examples "generates tokens"
    end

    context "with an addendum to the user agent string" do
      let(:opentok) { OpenTok::OpenTok.new api_key, api_secret, :ua_addendum => ua_addendum }
      let(:ua_addendum) { "BOOYAH"}

      it { should be_an_instance_of(OpenTok::OpenTok) }

      it "should have a ua_addendum property" do
        expect(opentok.ua_addendum).to eq ua_addendum
      end

      # NOTE: ua_addendum is hardcoded into cassette
      it "should append the addendum to the user agent header", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
        session = opentok.create_session
        expect(session).to be_an_instance_of OpenTok::Session
      end
    end
  end

  context "http client errors" do
    let(:api_key) { "123456" }
    let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }

    before(:each) do
      stub_request(:post, 'https://api.opentok.com/session/create').to_timeout
    end

    subject { -> { opentok.create_session } }

    it { should raise_error(OpenTok::OpenTokError) }
  end

  # ah, the magic of duck typing. the errors raised don't have any specific description
  # see discussion here: https://www.ruby-forum.com/topic/194593
  context "when initialized improperly" do
    context "with no arguments" do
      subject { -> { @opentok = OpenTok::OpenTok.new } }
      it { should raise_error }
    end
    context "with just an api_key" do
      subject { -> { @opentok = OpenTok::OpenTok.new "123456" } }
      it { should raise_error }
    end
    context "with arguments of the wrong type" do
      subject { -> { @opentok = OpenTok::OpenTok.new api_key: "123456" } }
      it { should raise_error }
    end
  end

end
