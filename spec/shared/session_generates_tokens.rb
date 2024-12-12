require "opentok/constants"
require "matchers/token"

shared_examples "session generates tokens" do
  describe "#generate_token" do
    before(:each) do
      now = Time.parse("2017-04-18 20:17:40 +1000")
      allow(Time).to receive(:now) { now }
    end

    # these must be known quantities because generate_token will have to verify that the session_id
    # belongs to the api_key, it doesn't have the luxury of getting that type of failure in an error
    # response from the server
    let(:api_key) { "123456" }
    let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
    let(:session_id) { "1_MX4xMjM0NTZ-flNhdCBNYXIgMTUgMTQ6NDI6MjMgUERUIDIwMTR-MC40OTAxMzAyNX4" }
    let(:default_role) { :publisher }
    let(:ist) { "project" }
    let(:scope) { "session.connect" }

    context "when token type is T1" do
      it "generates plain tokens" do
        plain_token = session.generate_token :token_type => "T1"
        expect(plain_token).to be_an_instance_of String
        expect(plain_token).to carry_t1_token_data :session_id => session_id
        expect(plain_token).to carry_t1_token_data :api_key => api_key
        expect(plain_token).to carry_t1_token_data :role => default_role
        expect(plain_token).to carry_t1_token_data [:nonce, :create_time]
        expect(plain_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with an expire time" do
        expire_time = Time.now + (60*60*24)
        expiring_token = session.generate_token :expire_time => expire_time, :token_type => "T1"
        expect(expiring_token).to be_an_instance_of String
        expect(expiring_token).to carry_t1_token_data :session_id => session_id
        expect(expiring_token).to carry_t1_token_data :api_key => api_key
        expect(expiring_token).to carry_t1_token_data :role => default_role
        expect(expiring_token).to carry_t1_token_data :expire_time => expire_time.to_i
        expect(expiring_token).to carry_t1_token_data [:nonce, :create_time]
        expect(expiring_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with a role" do
        role = :moderator
        role_token = session.generate_token :role => role, :token_type => "T1"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_t1_token_data :session_id => session_id
        expect(role_token).to carry_t1_token_data :api_key => api_key
        expect(role_token).to carry_t1_token_data :role => role
        expect(role_token).to carry_t1_token_data [:nonce, :create_time]
        expect(role_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with data" do
        data = "name=Johnny"
        data_bearing_token = session.generate_token :data => data, :token_type => "T1"
        expect(data_bearing_token).to be_an_instance_of String
        expect(data_bearing_token).to carry_t1_token_data :session_id => session_id
        expect(data_bearing_token).to carry_t1_token_data :api_key => api_key
        expect(data_bearing_token).to carry_t1_token_data :role => default_role
        expect(data_bearing_token).to carry_t1_token_data :data => data
        expect(data_bearing_token).to carry_t1_token_data [:nonce, :create_time]
        expect(data_bearing_token).to carry_valid_t1_token_signature api_secret
      end
    end

    context "when token type is JWT" do
      it "generates plain tokens" do
        plain_token = session.generate_token :token_type => "JWT"
        expect(plain_token).to be_an_instance_of String
        expect(plain_token).to carry_jwt_token_data :session_id => session_id
        expect(plain_token).to carry_jwt_token_data :iss => api_key
        expect(plain_token).to carry_jwt_token_data :ist => ist
        expect(plain_token).to carry_jwt_token_data :scope => scope
        expect(plain_token).to carry_jwt_token_data :role => default_role
        expect(plain_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(plain_token).to carry_valid_jwt_token_signature api_secret
      end

      it "generates tokens with a custom expire time" do
        expire_time = Time.now + (60*60*24)
        expiring_token = session.generate_token :expire_time => expire_time, :token_type => "JWT"
        expect(expiring_token).to be_an_instance_of String
        expect(expiring_token).to carry_jwt_token_data :session_id => session_id
        expect(expiring_token).to carry_jwt_token_data :iss => api_key
        expect(expiring_token).to carry_jwt_token_data :ist => ist
        expect(expiring_token).to carry_jwt_token_data :scope => scope
        expect(expiring_token).to carry_jwt_token_data :role => default_role
        expect(expiring_token).to carry_jwt_token_data :exp => expire_time.to_i
        expect(expiring_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(expiring_token).to carry_valid_jwt_token_signature api_secret
      end

      it "generates tokens with a non-default role" do
        role = :moderator
        role_token = session.generate_token :role => role, :token_type => "JWT"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_jwt_token_data :session_id => session_id
        expect(role_token).to carry_jwt_token_data :iss => api_key
        expect(role_token).to carry_jwt_token_data :ist => ist
        expect(role_token).to carry_jwt_token_data :scope => scope
        expect(role_token).to carry_jwt_token_data :role => role
        expect(role_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(role_token).to carry_valid_jwt_token_signature api_secret
      end

      it "generates tokens with data" do
        data = "name=Johnny"
        data_bearing_token = session.generate_token :data => data, :token_type => "JWT"
        expect(data_bearing_token).to be_an_instance_of String
        expect(data_bearing_token).to carry_jwt_token_data :session_id => session_id
        expect(data_bearing_token).to carry_jwt_token_data :iss => api_key
        expect(data_bearing_token).to carry_jwt_token_data :ist => ist
        expect(data_bearing_token).to carry_jwt_token_data :scope => scope
        expect(data_bearing_token).to carry_jwt_token_data :role => default_role
        expect(data_bearing_token).to carry_jwt_token_data :connection_data => data
        expect(data_bearing_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(data_bearing_token).to carry_valid_jwt_token_signature api_secret
      end
    end

    context "when token type is not specified" do
      it "generates a JWT token by default" do
        default_token = session.generate_token
        expect(default_token).to be_an_instance_of String
        expect(default_token).to carry_valid_jwt_token_signature api_secret
      end
    end

    context "when token type is invalid" do
      it "raises an error" do
        expect {  session.generate_token :token_type => "invalid_token_type" }.to raise_error
      end
    end

    # TODO a context about using a bad session_id
  end

end
