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

      # request.post("/archive", :sessionId => session_id, :name => name) do |response, code|
      #   if code < 300
      #     Archive.new self, response
      #   elsif code == 400
      #     raise OpenTokException.new code, "Session is invalid"

      #   elsif code == 403
      #     raise OpenTokAuthenticationError

      #   elsif code == 404
      #     raise OpenTokSessionNotFoundError

      #   elsif code == 409
      #     raise OpenTokConflictError, response["message"]

      #   elsif code
      #     raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"

      #   end
      # end
    end

    def find(archive_id)
      raise ArgumentError, "archive_id not provied" if archive_id.to_s.empty?
      archive_json = @client.get_archive(archive_id.to_s)
      Archive.new self, archive_json
      # request.get("/archive/#{archive_id}") do |response, code|
      #   if code < 300
      #     Archive.new self, response

      #   elsif code == 403
      #     raise OpenTokAuthenticationError

      #   elsif code == 404
      #     raise OpenTokArchiveNotFoundError

      #   else
      #     raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"

      #   end
      # end

    end

    def all(options = {})
      raise ArgumentError, "Limit is invalid" unless options[:count].nil? or (0..100).include? options[:count]
      archive_list_json = @client.list_archives(options[:offset], options[:count])
      ArchiveList.new self, archive_list_json

      # request.get("/archive?#{args}") do |response, code|
      #   if code < 300
      #     ArchiveList.new self, response

      #   elsif code == 403
      #     raise OpenTokAuthenticationError

      #   else
      #     raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"
      #   end

      # end
    end

    def stop_by_id(archive_id)
      raise ArgumentError, "archive_id not provied" if archive_id.to_s.empty?
      archive_json = @client.stop_archive(archive_id)
      Archive.new self, archive_json
      # request.post("/archive/#{archive_id}/stop", {}) do |response, code|
      #   if code < 300
      #     Archive.new self, response

      #   elsif code == 403
      #     raise OpenTokAuthenticationError

      #   elsif code == 404
      #     raise OpenTokArchiveNotFoundError

      #   elsif code == 409
      #     raise OpenTokNotArchivingError

      #   else
      #     raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"

      #   end
      # end
    end

    def delete_by_id(archive_id)
      raise ArgumentError, "archive_id not provied" if archive_id.to_s.empty?
      response = @client.delete_archive(archive_id)
      (200..300).include? response.code
      # request.delete("/archive/#{archive_id}") do |response, code|
      #   if code < 300
      #     true

      #   elsif code == 403
      #     raise OpenTokAuthenticationError

      #   elsif code == 404
      #     raise OpenTokArchiveNotFoundError

      #   else
      #     raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"

      #   end
      # end
    end

  end
end
