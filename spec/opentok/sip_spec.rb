require "opentok/opentok"
require "opentok/sip"
require "spec_helper"

describe OpenTok::Sip do
  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:expiring_token) { "TOKENID" }
  let(:sip_uri) { "sip:+15128675309@acme.pstn.example.com;transport=tls" }
  let(:sip_username) { "bob" }
  let(:sip_password) { "abc123" }
  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:sip) { opentok.sip }
  subject { sip }

  it "receives a valid response", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    opts = { "auth" => { "username" => sip_username,
                         "password" => sip_password },
             "secure" => "true"
    }
    response = sip.dial(session_id, expiring_token, sip_uri, opts)
    expect(response).not_to be_nil
  end
end
