require "opentok/client"
require "opentok/archive"
require "opentok/archive_list"

module OpenTok
  class Archives

    def initialize(client)
      @client = client
    end

    def create(session_id, options = {})
      raise ArgumentError, "session_id not provied" if session_id.to_s.empty?
      opts = Hash.new
      opts[:name] = options[:name].to_s || options["name"].to_s
      archive_json = @client.start_archive(session_id, opts)
      Archive.new self, archive_json
    end

    def find(archive_id)
      raise ArgumentError, "archive_id not provied" if archive_id.to_s.empty?
      archive_json = @client.get_archive(archive_id.to_s)
      Archive.new self, archive_json
    end

    def all(options = {})
      raise ArgumentError, "Limit is invalid" unless options[:count].nil? or (0..100).include? options[:count]
      archive_list_json = @client.list_archives(options[:offset], options[:count])
      ArchiveList.new self, archive_list_json
    end

    def stop_by_id(archive_id)
      raise ArgumentError, "archive_id not provied" if archive_id.to_s.empty?
      archive_json = @client.stop_archive(archive_id)
      Archive.new self, archive_json
    end

    def delete_by_id(archive_id)
      raise ArgumentError, "archive_id not provied" if archive_id.to_s.empty?
      response = @client.delete_archive(archive_id)
      (200..300).include? response.code
    end

  end
end
