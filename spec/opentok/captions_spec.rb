require "opentok/opentok"
require "opentok/captions"
require "opentok/version"
require "spec_helper"

describe OpenTok::Captions do
  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:captions_id) { "CAPTIONSID" }
  let(:expiring_token) { "TOKENID" }
  let(:status_callback_url) { "https://example.com/captions/status" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:captions) { opentok.captions }
  subject { captions }

  it "receives a valid response when starting captions", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = captions.start(session_id, expiring_token)
    expect(response).not_to be_nil
    expect(response.code).to eq(202)
  end

  it "receives a valid response when starting captions with options", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    opts = { "language_code" => "en-GB",
             "max_duration" => 5000,
             "partial_captions" => false,
             "status_callback_url" => status_callback_url
           }

    response = captions.start(session_id, expiring_token, opts)
    expect(response).not_to be_nil
    expect(response.code).to eq(202)
  end

  it "receives a valid response when stopping captions", :vcr => { :erb => { :version => OpenTok::VERSION + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}"} } do
    response = captions.stop(captions_id)
    expect(response.code).to eq(202)
  end
end
