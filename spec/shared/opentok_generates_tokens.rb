require "opentok/constants"
require "matchers/token"

shared_examples "opentok generates tokens" do
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
        plain_token = opentok.generate_token session_id, :token_type => "T1"
        expect(plain_token).to be_an_instance_of String
        expect(plain_token).to carry_t1_token_data :session_id => session_id
        expect(plain_token).to carry_t1_token_data :api_key => api_key
        expect(plain_token).to carry_t1_token_data :role => default_role
        expect(plain_token).to carry_t1_token_data [:nonce, :create_time]
        expect(plain_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with an expire time" do
        expire_time = Time.now + (60*60*24)
        expiring_token = opentok.generate_token session_id, :expire_time => expire_time, :token_type => "T1"
        expect(expiring_token).to be_an_instance_of String
        expect(expiring_token).to carry_t1_token_data :session_id => session_id
        expect(expiring_token).to carry_t1_token_data :api_key => api_key
        expect(expiring_token).to carry_t1_token_data :role => default_role
        expect(expiring_token).to carry_t1_token_data :expire_time => expire_time.to_i
        expect(expiring_token).to carry_t1_token_data [:nonce, :create_time]
        expect(expiring_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with an integer expire time" do
        expire_time = Time.now.to_i + (60*60*24)
        expiring_token = opentok.generate_token session_id, :expire_time => expire_time, :token_type => "T1"
        expect(expiring_token).to be_an_instance_of String
        expect(expiring_token).to carry_t1_token_data :session_id => session_id
        expect(expiring_token).to carry_t1_token_data :api_key => api_key
        expect(expiring_token).to carry_t1_token_data :role => default_role
        expect(expiring_token).to carry_t1_token_data :expire_time => expire_time
        expect(expiring_token).to carry_t1_token_data [:nonce, :create_time]
        expect(expiring_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with a publisher role" do
        role = :publisher
        role_token = opentok.generate_token session_id, :role => role, :token_type => "T1"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_t1_token_data :session_id => session_id
        expect(role_token).to carry_t1_token_data :api_key => api_key
        expect(role_token).to carry_t1_token_data :role => role
        expect(role_token).to carry_t1_token_data [:nonce, :create_time]
        expect(role_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with a subscriber role" do
        role = :subscriber
        role_token = opentok.generate_token session_id, :role => role, :token_type => "T1"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_t1_token_data :session_id => session_id
        expect(role_token).to carry_t1_token_data :api_key => api_key
        expect(role_token).to carry_t1_token_data :role => role
        expect(role_token).to carry_t1_token_data [:nonce, :create_time]
        expect(role_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with a moderator role" do
        role = :moderator
        role_token = opentok.generate_token session_id, :role => role, :token_type => "T1"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_t1_token_data :session_id => session_id
        expect(role_token).to carry_t1_token_data :api_key => api_key
        expect(role_token).to carry_t1_token_data :role => role
        expect(role_token).to carry_t1_token_data [:nonce, :create_time]
        expect(role_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with a publisheronly role" do
        role = :publisheronly
        role_token = opentok.generate_token session_id, :role => role, :token_type => "T1"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_t1_token_data :session_id => session_id
        expect(role_token).to carry_t1_token_data :api_key => api_key
        expect(role_token).to carry_t1_token_data :role => role
        expect(role_token).to carry_t1_token_data [:nonce, :create_time]
        expect(role_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with data" do
        data = "name=Johnny"
        data_bearing_token = opentok.generate_token session_id, :data => data, :token_type => "T1"
        expect(data_bearing_token).to be_an_instance_of String
        expect(data_bearing_token).to carry_t1_token_data :session_id => session_id
        expect(data_bearing_token).to carry_t1_token_data :api_key => api_key
        expect(data_bearing_token).to carry_t1_token_data :role => default_role
        expect(data_bearing_token).to carry_t1_token_data :data => data
        expect(data_bearing_token).to carry_t1_token_data [:nonce, :create_time]
        expect(data_bearing_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with initial layout classes" do
        layout_classes = ["focus", "small"]
        layout_class_bearing_token = opentok.generate_token session_id, :initial_layout_class_list => layout_classes, :token_type => "T1"
        expect(layout_class_bearing_token).to be_an_instance_of String
        expect(layout_class_bearing_token).to carry_t1_token_data :session_id => session_id
        expect(layout_class_bearing_token).to carry_t1_token_data :api_key => api_key
        expect(layout_class_bearing_token).to carry_t1_token_data :role => default_role
        expect(layout_class_bearing_token).to carry_t1_token_data :initial_layout_class_list => layout_classes.join(' ')
        expect(layout_class_bearing_token).to carry_t1_token_data [:nonce, :create_time]
        expect(layout_class_bearing_token).to carry_valid_t1_token_signature api_secret
      end

      it "generates tokens with one initial layout class" do
        layout_class = "focus"
        layout_class_bearing_token = opentok.generate_token session_id, :initial_layout_class_list => layout_class, :token_type => "T1"
        expect(layout_class_bearing_token).to be_an_instance_of String
        expect(layout_class_bearing_token).to carry_t1_token_data :session_id => session_id
        expect(layout_class_bearing_token).to carry_t1_token_data :api_key => api_key
        expect(layout_class_bearing_token).to carry_t1_token_data :role => default_role
        expect(layout_class_bearing_token).to carry_t1_token_data :initial_layout_class_list => layout_class
        expect(layout_class_bearing_token).to carry_t1_token_data [:nonce, :create_time]
        expect(layout_class_bearing_token).to carry_valid_t1_token_signature api_secret
      end

      context "when the role is invalid" do
        it "raises an error" do
          expect {  opentok.generate_token session_id, :role => :invalid_role, :token_type => "T1" }.to raise_error
        end
      end
    end

    context "when token type is JWT" do
      it "generates plain tokens" do
        plain_token = opentok.generate_token session_id, :token_type => "JWT"
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
        expiring_token = opentok.generate_token session_id, :expire_time => expire_time, :token_type => "JWT"
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

      it "generates tokens with an integer expire time" do
        expire_time = Time.now.to_i + (60*60*24)
        expiring_token = opentok.generate_token session_id, :expire_time => expire_time, :token_type => "JWT"
        expect(expiring_token).to be_an_instance_of String
        expect(expiring_token).to carry_jwt_token_data :session_id => session_id
        expect(expiring_token).to carry_jwt_token_data :iss => api_key
        expect(expiring_token).to carry_jwt_token_data :ist => ist
        expect(expiring_token).to carry_jwt_token_data :scope => scope
        expect(expiring_token).to carry_jwt_token_data :role => default_role
        expect(expiring_token).to carry_jwt_token_data :exp => expire_time
        expect(expiring_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(expiring_token).to carry_valid_jwt_token_signature api_secret
      end

      it "generates tokens with a publisher role" do
        role = :publisher
        role_token = opentok.generate_token session_id, :role => role, :token_type => "JWT"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_jwt_token_data :session_id => session_id
        expect(role_token).to carry_jwt_token_data :iss => api_key
        expect(role_token).to carry_jwt_token_data :ist => ist
        expect(role_token).to carry_jwt_token_data :scope => scope
        expect(role_token).to carry_jwt_token_data :role => role
        expect(role_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(role_token).to carry_valid_jwt_token_signature api_secret
      end

      it "generates tokens with a subscriber role" do
        role = :subscriber
        role_token = opentok.generate_token session_id, :role => role, :token_type => "JWT"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_jwt_token_data :session_id => session_id
        expect(role_token).to carry_jwt_token_data :iss => api_key
        expect(role_token).to carry_jwt_token_data :ist => ist
        expect(role_token).to carry_jwt_token_data :scope => scope
        expect(role_token).to carry_jwt_token_data :role => role
        expect(role_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(role_token).to carry_valid_jwt_token_signature api_secret
      end

      it "generates tokens with a moderator role" do
        role = :moderator
        role_token = opentok.generate_token session_id, :role => role, :token_type => "JWT"
        expect(role_token).to be_an_instance_of String
        expect(role_token).to carry_jwt_token_data :session_id => session_id
        expect(role_token).to carry_jwt_token_data :iss => api_key
        expect(role_token).to carry_jwt_token_data :ist => ist
        expect(role_token).to carry_jwt_token_data :scope => scope
        expect(role_token).to carry_jwt_token_data :role => role
        expect(role_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(role_token).to carry_valid_jwt_token_signature api_secret
      end

      it "generates tokens with a publisheronly role" do
        role = :publisheronly
        role_token = opentok.generate_token session_id, :role => role, :token_type => "JWT"
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
        data_bearing_token = opentok.generate_token session_id, :data => data, :token_type => "JWT"
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

      it "generates tokens with initial layout classes" do
        layout_classes = ["focus", "small"]
        layout_class_bearing_token = opentok.generate_token session_id, :initial_layout_class_list => layout_classes, :token_type => "JWT"
        expect(layout_class_bearing_token).to be_an_instance_of String
        expect(layout_class_bearing_token).to carry_jwt_token_data :session_id => session_id
        expect(layout_class_bearing_token).to carry_jwt_token_data :iss => api_key
        expect(layout_class_bearing_token).to carry_jwt_token_data :ist => ist
        expect(layout_class_bearing_token).to carry_jwt_token_data :scope => scope
        expect(layout_class_bearing_token).to carry_jwt_token_data :role => default_role
        expect(layout_class_bearing_token).to carry_jwt_token_data :initial_layout_class_list => layout_classes.join(' ')
        expect(layout_class_bearing_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(layout_class_bearing_token).to carry_valid_jwt_token_signature api_secret
      end

      it "generates tokens with one initial layout class" do
        layout_class = "focus"
        layout_class_bearing_token = opentok.generate_token session_id, :initial_layout_class_list => layout_class, :token_type => "JWT"
        expect(layout_class_bearing_token).to be_an_instance_of String
        expect(layout_class_bearing_token).to carry_jwt_token_data :session_id => session_id
        expect(layout_class_bearing_token).to carry_jwt_token_data :iss => api_key
        expect(layout_class_bearing_token).to carry_jwt_token_data :ist => ist
        expect(layout_class_bearing_token).to carry_jwt_token_data :scope => scope
        expect(layout_class_bearing_token).to carry_jwt_token_data :role => default_role
        expect(layout_class_bearing_token).to carry_jwt_token_data :initial_layout_class_list => layout_class
        expect(layout_class_bearing_token).to carry_jwt_token_data [:ist, :iat, :nonce]
        expect(layout_class_bearing_token).to carry_valid_jwt_token_signature api_secret
      end

      context "when the role is invalid" do
        it "raises an error" do
          expect {  opentok.generate_token session_id, :role => :invalid_role, :token_type => "JWT" }.to raise_error
        end
      end
    end

    context "when token type is not specified" do
      it "generates a JWT token by default" do
        default_token = opentok.generate_token session_id
        expect(default_token).to be_an_instance_of String
        expect(default_token).to carry_valid_jwt_token_signature api_secret
      end
    end

    context "when token type is invalid" do
      it "raises an error" do
        expect {  opentok.generate_token session_id, :token_type => "invalid_token_type" }.to raise_error
      end
    end

    # TODO a context about using a bad session_id
  end

end
