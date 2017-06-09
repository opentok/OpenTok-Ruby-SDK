require "opentok/archives"
require "opentok/opentok"
require "opentok/version"
require "opentok/archive"
require "opentok/archive_list"

require "spec_helper"

describe OpenTok::Archives do

  before(:each) do
    now = Time.parse("2017-04-18 20:17:40 +1000")
    allow(Time).to receive(:now) { now }
  end

  let(:api_key) { "123456" }
  let(:api_secret) { "1234567890abcdef1234567890abcdef1234567890" }
  let(:session_id) { "SESSIONID" }
  let(:archive_name) { "ARCHIVE NAME" }
  let(:started_archive_id) { "30b3ebf1-ba36-4f5b-8def-6f70d9986fe9" }
  let(:findable_archive_id) { "f6e7ee58-d6cf-4a59-896b-6d56b158ec71" }
  let(:findable_paused_archive_id) { "f6e7ee58-d6cf-4a59-896b-6d56b158ec71" }
  let(:deletable_archive_id) { "832641bf-5dbf-41a1-ad94-fea213e59a92" }

  let(:opentok) { OpenTok::OpenTok.new api_key, api_secret }
  let(:archives) { opentok.archives }
  subject { archives }

  it { should be_an_instance_of OpenTok::Archives }

  it "should create archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.create session_id
    expect(archive).to be_an_instance_of OpenTok::Archive
    expect(archive.session_id).to eq session_id
    expect(archive.id).not_to be_nil
  end

  it "should create named archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.create session_id, :name => archive_name
    expect(archive).to be_an_instance_of OpenTok::Archive
    expect(archive.session_id).to eq session_id
    expect(archive.name).to eq archive_name
  end

  it "should create audio only archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.create session_id, :has_video => false
    expect(archive).to be_an_instance_of OpenTok::Archive
    expect(archive.session_id).to eq session_id
    expect(archive.has_video).to be false
    expect(archive.has_audio).to be true
  end

  it "should create individual archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.create session_id, :output_mode => :individual
    expect(archive).to be_an_instance_of OpenTok::Archive
    expect(archive.session_id).to eq session_id
    expect(archive.output_mode).to eq :individual
  end

  it "should stop archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.stop_by_id started_archive_id
    expect(archive).to be_an_instance_of OpenTok::Archive
    expect(archive.status).to eq "stopped"
  end

  it "should find archives by id", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.find findable_archive_id
    expect(archive).to be_an_instance_of OpenTok::Archive
    expect(archive.id).to eq findable_archive_id
  end

  it "should find paused archives by id", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.find findable_paused_archive_id
    expect(archive).to be_an_instance_of OpenTok::Archive
    expect(archive.id).to eq findable_paused_archive_id
    expect(archive.status).to eq "paused"
  end

  it "should delete an archive by id", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    success = archives.delete_by_id deletable_archive_id
    expect(success).to be_true
    # expect(archive.status).to eq ""
  end

  it "should find expired archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.find findable_archive_id
    expect(archive).to be_an_instance_of OpenTok::Archive
    expect(archive.status).to eq "expired"
  end

  it "should find archives with unknown properties", :vcr => { :erb => { :version => OpenTok::VERSION } } do
    archive = archives.find findable_archive_id
    expect(archive).to be_an_instance_of OpenTok::Archive
  end

  # TODO: context "with a session that has no participants" do
  #   let(:session_id) { "" }
  #   it "should refuse to create archives with appropriate error" do
  #     expect { archives.create session_id }.to raise_error
  #   end
  # end

  context "when many archives are created" do
    it "should return all archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.total).to eq 6
      expect(archive_list.count).to eq 6
    end

    it "should return archives with an offset", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all :offset => 3
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.total).to eq 3
      expect(archive_list.count).to eq 3
    end

    it "should return count number of archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all :count => 2
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.count).to eq 2
      expect(archive_list.count).to eq 2
    end

    it "should return part of the archives when using offset and count", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all :count => 4, :offset => 2
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.count).to eq 4
      expect(archive_list.count).to eq 4
    end

    it "should return session archives", :vcr => { :erb => { :version => OpenTok::VERSION } } do
      archive_list = archives.all :sessionId => session_id
      expect(archive_list).to be_an_instance_of OpenTok::ArchiveList
      expect(archive_list.total).to eq 3
      expect(archive_list.count).to eq 3
    end
  end

  context "http client errors" do
    before(:each) do
      stub_request(:get, /.*\/v2\/partner.*/).to_timeout
    end

    subject { -> { archives.all } }

    it { should raise_error(OpenTok::OpenTokError) }
  end

end
