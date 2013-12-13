require 'spec_helper'

describe OpenTok do

  let(:api_key) { '459782' }
  let(:api_secret) { '***REMOVED***' }
  let(:api_url) { 'http://api.opentok.com' }
  let(:host) { 'localhost' }

  subject { OpenTok::OpenTokSDK.new api_key, api_secret }

  describe "test Initializers" do
    it "should be backwards compatible if user set api URL with no effect" do
      opentok = OpenTok::OpenTokSDK.new api_key, api_secret, {:api_url => "bla bla"}
      opentok.api_url.should eq api_url
    end

    it "should be OpenTok SDK Object" do
      subject.should be_instance_of OpenTok::OpenTokSDK
    end

    its(:api_url) { should == api_url }
  end

  describe "Generate Sessions" do
    use_vcr_cassette "session"

    let(:opentok) { OpenTok::OpenTokSDK.new api_key, api_secret }

    it "should generate valid session" do
      session = opentok.create_session host
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end

    it "should generate valid p2p session" do
      # Creating Session object with p2p enabled
      sessionProperties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}    # or disabled
      session = opentok.createSession( @location, sessionProperties )
      session.to_s.should match(/\A[0-9A-z_-]{40,}\Z/)
    end
  end

  describe "invalid Sessions" do
    use_vcr_cassette "invalidSession"
    it "should raise an exception with an invalid key and secret" do
      invalidOT = OpenTok::OpenTokSDK.new 0, ''

      expect{
        session = invalidOT.create_session host
      }.to raise_error OpenTok::OpenTokException
    end
  end

  describe "Generate Tokens" do
    let(:session) { subject.createSession host }

    it "should raise error" do
      expect { subject.generateToken({:role=>OpenTok::RoleConstants::MODERATOR}) }.to raise_error
    end
    it "should generate valid token" do
      token = subject.generate_token({:session_id => session, :role=>OpenTok::RoleConstants::MODERATOR})
      token.should match(/(T1==)+[0-9A-z_]+/)
    end
    it "should generate valid token camelCase" do
      token = subject.generateToken({:session_id => session, :role=>OpenTok::RoleConstants::MODERATOR})
      token.should match(/(T1==)+[0-9A-z_]+/)
    end
    it "should be able to set parameters in token" do
      token = subject.generate_token :session_id => session, :role=> OpenTok::RoleConstants::PUBLISHER, :connection_data => "username=Bob,level=4"
      str = token[4..token.length]
      decoded = Base64.decode64(str)
      decoded.should match(/.*username%3DBob.*/)
      decoded.should match(/.*level%3D4.*/)
    end
  end

  describe "Archives" do

    it "should return an OpenTok::Archives instance" do
      subject.archives.should be_instance_of OpenTok::Archives
    end

    describe "create" do

      it "should return an Archive" do
        VCR.use_cassette("startArchive") do
          archive = subject.archives.create("2_MX40NTk3ODJ-flRodSBEZWMgMTIgMjA6MTk6MjUgUFNUIDIwMTN-MC44MjMzNDM4fg")
          # puts archive.to_s
          archive.should be_instance_of OpenTok::Archive
        end
      end

      it "should raise an error if session is nil" do
          begin
            subject.archives.create(nil)
          rescue => e
            e.should be_instance_of ArgumentError
          end
      end

      it "should raise an error if the session ID is invalid" do
        VCR.use_cassette('startArchiveSessionNotFound') do
          expect {
            archive = subject.archives.create("1_MX40NTk3ODJ-flRodSBEZWMgMTIgMjA6NTA6MTQgUFNUIDIwMTN-MC43OTYwMDQ5NX4")
          }.to raise_error { |error|
            error.should be_a OpenTok::OpenTokException
            error.message.should eq "Session not found"
            error.code.should eq 404
          }
        end
      end

      it "should raise an error if the session is peer to peer or already being recorded" do
        VCR.use_cassette('startArchiveSessionConflict') do
          expect {
            archive = subject.archives.create("1_MX40NTk3ODJ-flRodSBEZWMgMTIgMjA6NTA6MTQgUFNUIDIwMTN-MC43OTYwMDQ5NX4")
          }.to raise_error { |error|
            error.should be_a OpenTok::OpenTokConflictError
            error.message.should eq "A recording of the session is is already in progress."
            error.code.should eq 409
          }
        end
      end

      it "should raise an error if any other HTTP status code is returned" do
        VCR.use_cassette('startArchiveSessionUnexpected') do
          expect {
            archive = subject.archives.create("1_MX40NTk3ODJ-flRodSBEZWMgMTIgMjA6NTA6MTQgUFNUIDIwMTN-MC43OTYwMDQ5NX4")
          }.to raise_error { |error|
            error.should be_a OpenTok::OpenTokUnexpectedError
            error.message.should eq "Unexpected server error"
            error.code.should eq 500
          }
        end
        
      end

    end

    describe "find" do

      it "should find a valid archive" do
        VCR.use_cassette("findArchive") do
          archive = subject.archives.find("0f7fc60a-5882-4ebf-b87b-6d749b45de50")
          expect(archive).to be_a OpenTok::Archive
          expect(archive.created_at).to eql Time.new(2013, 12, 13, 16, 45, 9, "+11:00")
          expect(archive.duration).to eql 27
          expect(archive.id).to eql "0f7fc60a-5882-4ebf-b87b-6d749b45de50"
          expect(archive.name).to eql "bdb60a69-3ed9-4690-b8bf-383eb6bf9271"
          expect(archive.partner_id).to eql 459782
          expect(archive.reason).to eql ""
          expect(archive.session_id).to eql "1_MX40NTk3ODJ-flRodSBEZWMgMTIgMjA6NTA6MTQgUFNUIDIwMTN-MC43OTYwMDQ5NX4"
          expect(archive.size).to eql 4714712
          expect(archive.status).to eql "available"
          expect(archive.url).to eql "http://file.mp4"
        end
      end

      it "should raise an error if the archive ID is invalid" do
        expect { archive = subject.archives.find(nil) }.to raise_error { |error|
          expect(error).to be_instance_of ArgumentError
          expect(error.message).to eql "archive_id not provied"
        }
      end

      it "should raise an error if the archive ID is not found" do
        VCR.use_cassette("findArchiveInvalid") do
          expect { subject.archives.find("8D3F0FC3-88B3-41B3-815E-E2970FF44018") }.to raise_error { |error|
            expect(error).to be_instance_of OpenTok::OpenTokArchiveNotFoundError
            expect(error.code).to eql 404
            expect(error.message).to eql "Archive not found"
          }
        end
      end

      it "should raise an error if the archive ID is not found" do
        VCR.use_cassette("findArchiveServerError") do
          expect { subject.archives.find("8D3F0FC3-88B3-41B3-815E-E2970FF44018") }.to raise_error { |error|
            expect(error).to be_instance_of OpenTok::OpenTokUnexpectedError
            expect(error.code).to eql 500
            expect(error.message).to eql "Unexpected server error"
          }
        end
      end

    end

    describe "all" do

      it "should return an ArchiveList" do
        VCR.use_cassette("allArchives") do
          archives = subject.archives.all
          expect(archives).to be_instance_of OpenTok::ArchiveList
          expect(archives[0]).to be_instance_of OpenTok::Archive
          expect(archives[0]).to be_a OpenTok::Archive
          expect(archives[0].created_at).to eql Time.new(2013, 12, 13, 16, 45, 9, "+11:00")
          expect(archives[0].duration).to eql 27
          expect(archives[0].id).to eql "0f7fc60a-5882-4ebf-b87b-6d749b45de50"
          expect(archives[0].name).to eql "bdb60a69-3ed9-4690-b8bf-383eb6bf9271"
          expect(archives[0].partner_id).to eql 459782
          expect(archives[0].reason).to eql ""
          expect(archives[0].session_id).to eql "1_MX40NTk3ODJ-flRodSBEZWMgMTIgMjA6NTA6MTQgUFNUIDIwMTN-MC43OTYwMDQ5NX4"
          expect(archives[0].size).to eql 4714712
          expect(archives[0].status).to eql "available"
          expect(archives[0].url).to eql "http://file.mp4"
        end
      end

      it "should raise an error if limit is not a number" do
        expect { subject.archives.all :limit => "banana" }.to raise_error {|error|
          expect(error).to be_instance_of ArgumentError
          expect(error.message).to eql "Limit is invalid"
        }
      end

      it "should raise an error if limit is > 1000" do
        expect { subject.archives.all :limit => 1000000 }.to raise_error {|error|
          expect(error).to be_instance_of ArgumentError
          expect(error.message).to eql "Limit is invalid"
        }
      end

    end

    describe "Archive" do

      describe "stop" do
        it "should stop a recording archive" do
          VCR.use_cassette("stopArchive") do
            archive = subject.archives.find("cdd27670-f33a-40e8-b11d-388f58b525b1")
            expect(archive.status).to eql "started"
            archive.stop
            expect(archive).to be_a OpenTok::Archive
            expect(archive.created_at).to eql Time.new(2013, 12, 13, 17, 38, 57, "+11:00")
            expect(archive.duration).to eql 0
            expect(archive.id).to eql "cdd27670-f33a-40e8-b11d-388f58b525b1"
            expect(archive.name).to eql "e1b4fcaa-bde6-4a98-9f85-89d13ac564e6"
            expect(archive.partner_id).to eql 459782
            expect(archive.reason).to eql ""
            expect(archive.session_id).to eql "2_MX40NTk3ODJ-flRodSBEZWMgMTIgMjI6Mzg6MzUgUFNUIDIwMTN-MC45NDc0ODM5Nn4"
            expect(archive.size).to eql 0
            expect(archive.status).to eql "stopped"
            expect(archive.url).to eql nil
          end
        end

        it "should raise an error when stopping a stopped archive" do
          VCR.use_cassette('stopStoppedArchive') do
            archive = subject.archives.find("cc036f45-f479-48db-8c6c-ae9e4a508240")
            expect(archive.status).to eql 'available'
            expect { archive.stop }.to raise_error {|error|
              expect(error).to be_instance_of OpenTok::OpenTokNotArchivingError
              expect(error.code).to eql 409
              expect(error.message).to eql "Archive is not currently recording"
            }
          end
        end

      end

      describe "delete" do

        it "should delete an available archive" do
          VCR.use_cassette("deleteArchive") do
            archive = subject.archives.find("cdd27670-f33a-40e8-b11d-388f58b525b1")
            expect(archive.status).to eql "available"
            archive.delete
          end
          VCR.use_cassette("deletedArchive") do
            archive = subject.archives.find("cdd27670-f33a-40e8-b11d-388f58b525b1")
            expect(archive.status).to eql "deleted"
          end
        end

        it "should delete a deleted archive" do
          VCR.use_cassette("deleteDeletedArchive") do
            archive = subject.archives.find("cdd27670-f33a-40e8-b11d-388f58b525b1")
            expect(archive.status).to eql "deleted"
            archive.delete
          end
          VCR.use_cassette("deletedArchive") do
            archive = subject.archives.find("cdd27670-f33a-40e8-b11d-388f58b525b1")
            expect(archive.status).to eql "deleted"
          end
        end

        it "should raise an error on an unexpected server error" do
          archive = nil
          VCR.use_cassette("deleteArchive") do
            archive = subject.archives.find("cdd27670-f33a-40e8-b11d-388f58b525b1")
            expect(archive.status).to eql "available"
          end
          VCR.use_cassette("deleteServerError") do
            expect { archive.delete }.to raise_error {|error|
              expect(error).to be_instance_of OpenTok::OpenTokUnexpectedError
              expect(error.code).to eql 500
              expect(error.message).to eql "Unexpected server error"
            }
          end
        end

      end

    end

  end

end
