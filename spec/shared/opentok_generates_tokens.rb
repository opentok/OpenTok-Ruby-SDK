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

    it "generates plain tokens" do
      plain_token = opentok.generate_token session_id
      expect(plain_token).to be_an_instance_of String
      expect(plain_token).to carry_token_data :session_id => session_id
      expect(plain_token).to carry_token_data :api_key => api_key
      expect(plain_token).to carry_token_data :role => default_role
      expect(plain_token).to carry_token_data [:nonce, :create_time]
      expect(plain_token).to carry_valid_token_signature api_secret
    end

    it "generates tokens with an expire time" do
      expire_time = Time.now + (60*60*24)
      expiring_token = opentok.generate_token session_id, :expire_time => expire_time
      expect(expiring_token).to be_an_instance_of String
      expect(expiring_token).to carry_token_data :session_id => session_id
      expect(expiring_token).to carry_token_data :api_key => api_key
      expect(expiring_token).to carry_token_data :role => default_role
      expect(expiring_token).to carry_token_data :expire_time => expire_time.to_i
      expect(expiring_token).to carry_token_data [:nonce, :create_time]
      expect(expiring_token).to carry_valid_token_signature api_secret
    end

    it "generates tokens with an integer expire time" do
      expire_time = Time.now.to_i + (60*60*24)
      expiring_token = opentok.generate_token session_id, :expire_time => expire_time
      expect(expiring_token).to be_an_instance_of String
      expect(expiring_token).to carry_token_data :session_id => session_id
      expect(expiring_token).to carry_token_data :api_key => api_key
      expect(expiring_token).to carry_token_data :role => default_role
      expect(expiring_token).to carry_token_data :expire_time => expire_time
      expect(expiring_token).to carry_token_data [:nonce, :create_time]
      expect(expiring_token).to carry_valid_token_signature api_secret
    end

    it "generates tokens with a role" do
      role = :moderator
      role_token = opentok.generate_token session_id, :role => role
      expect(role_token).to be_an_instance_of String
      expect(role_token).to carry_token_data :session_id => session_id
      expect(role_token).to carry_token_data :api_key => api_key
      expect(role_token).to carry_token_data :role => role
      expect(role_token).to carry_token_data [:nonce, :create_time]
      expect(role_token).to carry_valid_token_signature api_secret
    end

    it "generates tokens with data" do
      data = "name=Johnny"
      data_bearing_token = opentok.generate_token session_id, :data => data
      expect(data_bearing_token).to be_an_instance_of String
      expect(data_bearing_token).to carry_token_data :session_id => session_id
      expect(data_bearing_token).to carry_token_data :api_key => api_key
      expect(data_bearing_token).to carry_token_data :role => default_role
      expect(data_bearing_token).to carry_token_data :data => data
      expect(data_bearing_token).to carry_token_data [:nonce, :create_time]
      expect(data_bearing_token).to carry_valid_token_signature api_secret
    end

    it "generates tokens with initial layout classes" do
      layout_classes = ["focus", "small"]
      layout_class_bearing_token = opentok.generate_token session_id, :initial_layout_classes => layout_classes
      expect(layout_class_bearing_token).to be_an_instance_of String
      expect(layout_class_bearing_token).to carry_token_data :session_id => session_id
      expect(layout_class_bearing_token).to carry_token_data :api_key => api_key
      expect(layout_class_bearing_token).to carry_token_data :role => default_role
      expect(layout_class_bearing_token).to carry_token_data :initial_layout_classes => layout_classes.join(' ')
      expect(layout_class_bearing_token).to carry_token_data [:nonce, :create_time]
      expect(layout_class_bearing_token).to carry_valid_token_signature api_secret
    end

    it "generates tokens with one initial layout class" do
      layout_class = "focus"
      layout_class_bearing_token = opentok.generate_token session_id, :initial_layout_classes => layout_class
      expect(layout_class_bearing_token).to be_an_instance_of String
      expect(layout_class_bearing_token).to carry_token_data :session_id => session_id
      expect(layout_class_bearing_token).to carry_token_data :api_key => api_key
      expect(layout_class_bearing_token).to carry_token_data :role => default_role
      expect(layout_class_bearing_token).to carry_token_data :initial_layout_classes => layout_class
      expect(layout_class_bearing_token).to carry_token_data [:nonce, :create_time]
      expect(layout_class_bearing_token).to carry_valid_token_signature api_secret
    end


    # TODO a context about using a bad session_id
  end

end
