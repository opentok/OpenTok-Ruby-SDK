require "opentok/constants"

shared_examples "generates tokens" do
  describe "#generate_token" do
    # these must be known quantities because generate_token will have to verify that the session_id
    # belongs to the api_key, it doesn't have the luxury of getting that type of failure in an error
    # response from the server
    let(:api_key) { "123456" }
    let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
    let(:session_id) { "1_MX4xMjM0NTZ-flNhdCBNYXIgMTUgMTQ6NDI6MjMgUERUIDIwMTR-MC40OTAxMzAyNX4" }

    it "generates plain tokens" do
      plain_token = opentok.generate_token session_id
      expect(plain_token).to be_an_instance_of String
      # TODO maybe some more expectation matchers about what a token can be described as
    end

    it "generates tokens with an expire time" do
      expiring_token = opentok.generate_token session_id, :expire_time => Time.now + (60*60*24)
      expect(expiring_token).to be_an_instance_of String
    end

    it "generates tokens with a role" do
      expiring_token = opentok.generate_token session_id, :role => :moderator
      expect(expiring_token).to be_an_instance_of String
    end

    it "generates tokens with data" do
      expiring_token = opentok.generate_token session_id, :data => "name=Johnny"
      expect(expiring_token).to be_an_instance_of String
    end

    # TODO a context about using a bad session_id
  end
end
