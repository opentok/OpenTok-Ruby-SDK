require "opentok/opentok"
require "shared/generates_tokens"

describe OpenTok::OpenTok do

  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  subject { opentok }

  context "when initialized properly" do

    let(:api_key) { "123456" }
    let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }

    it { should be_an_instance_of(OpenTok::OpenTok) }

    include_examples "generates tokens"

    context "with an api_key that's a number" do
      let(:api_key) { 123456 }
      it { should be_an_instance_of(OpenTok::OpenTok) }
      include_examples "generates tokens"
    end

    context "with an additional api_url" do
      let(:api_url) { "http://example.opentok.com" }
      let(:opentok) { OpenTok::OpenTok.new api_key, api_secret, api_url }
      it { should be_an_instance_of(OpenTok::OpenTok) }
      include_examples "generates tokens"
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
