require 'spec_helper'
require 'rexml/document'
require 'open_tok/exception'

describe OpenTok::OpenTokException do

  subject { OpenTok::OpenTokException }

  describe "when inhereted" do
    it "should include the subclass in the internal structure" do
      length = OpenTok::OpenTokException.exceptions.length
      Foo = Class.new OpenTok::OpenTokException do
        def self.http_code
          1000
        end
      end
      OpenTok::OpenTokException.exceptions.length.should eq length+1
    end
  end

  describe "when creating an exception" do

    let(:body_error) { "<Errors><error code='404'><itemNotFound message='Archive foo not found'/></error></Errors>"}

    let(:body_unknown_error) { "<Errors><error code='100'></error></Errors>"}

    it "should find the relevant child using the HTTP error code" do
      response = REXML::Document.new body_error
      OpenTok::OpenTokException.from_error(response).should be_instance_of OpenTok::OpenTokNotFound
    end

    it "should return the general exception if unknown HTTP error code" do
      response = REXML::Document.new body_unknown_error
      OpenTok::OpenTokException.from_error(response).should be_instance_of OpenTok::OpenTokException
    end
  end

end
