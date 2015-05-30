require "opentok/exceptions"
require "extensions/hash"

require "active_support/inflector"
require "httparty"

module OpenTok
  # @private For internal use by the SDK.
  class Client
    include HTTParty

    default_timeout 1 # Set HTTParty default timeout (open/read) to 1 second

    # TODO: expose a setting for http debugging for developers
    # debug_output $stdout

    def initialize(api_key, api_secret, api_url)
      self.class.base_uri api_url
      self.class.headers({
        "X-TB-PARTNER-AUTH" => "#{api_key}:#{api_secret}",
        "User-Agent" => "OpenTok-Ruby-SDK/#{VERSION}"
      })
      @api_key = api_key
    end

    def create_session(opts)
      opts.extend(HashExtensions)
      response = self.class.post("/session/create", :body => opts.camelize_keys!)
      case response.code
      when (200..300)
        response
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while creating a session. API Key: #{@api_key}"
      else
        raise OpenTokError, "Failed to create session. Response code: #{response.code}"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def start_archive(session_id, opts)
      opts.extend(HashExtensions)
      body = { "sessionId" => session_id }.merge(opts.camelize_keys!)
      response = self.class.post("/v2/partner/#{@api_key}/archive", {
        :body => body.to_json,
        :headers => { "Content-Type" => "application/json" }
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokArchiveError, "The archive could not be started. The request was invalid or the session has no connected clients."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while starting an archive. API Key: #{@api_key}"
      when 404
        raise OpenTokArchiveError, "The archive could not be started. The Session ID does not exist: #{session_id}"
      when 409
        raise OpenTokArchiveError, "The archive could not be started. The session could be peer-to-peer or the session is already being recorded."
      else
        raise OpenTokArchiveError, "The archive could not be started"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def get_archive(archive_id)
      response = self.class.get("/v2/partner/#{@api_key}/archive/#{archive_id}")
      case response.code
      when 200
        response
      when 400
        raise OpenTokArchiveError, "The archive could not be retrieved. The Archive ID was invalid: #{archive_id}"
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while retrieving an archive. API Key: #{@api_key}"
      else
        raise OpenTokArchiveError, "The archive could not be retrieved."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def list_archives(offset, count)
      query = Hash.new
      query[:offset] = offset unless offset.nil?
      query[:count] = count unless count.nil?
      response = self.class.get("/v2/partner/#{@api_key}/archive", {
        :query => query.empty? ? nil : query
      })
      case response.code
      when 200
        response
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while retrieving archives. API Key: #{@api_key}"
      else
        raise OpenTokArchiveError, "The archives could not be retrieved."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def stop_archive(archive_id)
      response = self.class.post("/v2/partner/#{@api_key}/archive/#{archive_id}/stop", {
        :headers => { "Content-Type" => "application/json" }
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokArchiveError, "The archive could not be stopped. The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while stopping an archive. API Key: #{@api_key}"
      when 404
        raise OpenTokArchiveError, "The archive could not be stopped. The Archive ID does not exist: #{archive_id}"
      when 409
        raise OpenTokArchiveError, "The archive could not be stopped. The archive is not currently recording."
      else
        raise OpenTokArchiveError, "The archive could not be stopped."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def delete_archive(archive_id)
      response = self.class.delete("/v2/partner/#{@api_key}/archive/#{archive_id}", {
        :headers => { "Content-Type" => "application/json" }
      })
      case response.code
      when 204
        response
      when 403
        raise OpenTokAuthenticationError, "Authentication failed or an invalid Archive ID was given while deleting an archive. API Key: #{@api_key}, Archive ID: #{archive_id}"
      when 409
        raise OpenTokArchiveError, "The archive could not be deleted. The status must be 'available', 'deleted', or 'uploaded'. Archive ID: #{archive_id}"
      else
        raise OpenTokArchiveError, "The archive could not be deleted."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end
  end
end
