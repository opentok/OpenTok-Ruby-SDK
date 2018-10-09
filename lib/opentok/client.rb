require "opentok/constants"
require "opentok/exceptions"
require "opentok/extensions/hash"
require "opentok/version"

require "active_support/inflector"
require "httparty"
require "jwt"

module OpenTok
  # @private For internal use by the SDK.
  class Client
    include HTTParty

    open_timeout 2 # Set HTTParty default timeout (open/read) to 2 seconds

    # TODO: expose a setting for http debugging for developers
    # debug_output $stdout

    def initialize(api_key, api_secret, api_url, ua_addendum="")
      self.class.base_uri api_url
      self.class.headers({
        "User-Agent" => "OpenTok-Ruby-SDK/#{VERSION}" + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" + (ua_addendum ? " #{ua_addendum}" : "")        
      })
      @api_key = api_key
      @api_secret = api_secret
    end

    def generate_jwt(api_key, api_secret)
      now = Time.now.to_i
      payload = {
        :iss => api_key,
        :iat => now,
        :exp => now + AUTH_EXPIRE
      }
      token = JWT.encode payload, api_secret, 'HS256', :ist => 'project'
      token
    end

    def generate_headers(extra_headers = {})
      defaults = { "X-OPENTOK-AUTH" => generate_jwt(@api_key, @api_secret) }
      defaults.merge extra_headers
    end

    def create_session(opts)
      opts.extend(HashExtensions)
      response = self.class.post("/session/create", {
        :body => opts.camelize_keys!,
        :headers => generate_headers
      })
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
      response = self.class.post("/v2/project/#{@api_key}/archive", {
        :body => body.to_json,
        :headers => generate_headers("Content-Type" => "application/json")
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
      response = self.class.get("/v2/project/#{@api_key}/archive/#{archive_id}", {
        :headers => generate_headers
      })
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

    def list_archives(offset, count, sessionId)
      query = Hash.new
      query[:offset] = offset unless offset.nil?
      query[:count] = count unless count.nil?
      query[:sessionId] = sessionId unless sessionId.nil?
      response = self.class.get("/v2/project/#{@api_key}/archive", {
        :query => query.empty? ? nil : query,
        :headers => generate_headers
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
      response = self.class.post("/v2/project/#{@api_key}/archive/#{archive_id}/stop", {
        :headers => generate_headers("Content-Type" => "application/json")
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
      response = self.class.delete("/v2/project/#{@api_key}/archive/#{archive_id}", {
        :headers => generate_headers("Content-Type" => "application/json")
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

    def layout_archive(archive_id, opts)
      opts.extend(HashExtensions)
      response = self.class.put("/v2/project/#{@api_key}/archive/#{archive_id}/layout", {
          :body => opts.camelize_keys!.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokArchiveError, "Setting the layout failed. The request was invalid or invalid layout options were given."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed. API Key: #{@api_key}"
      when 500
        raise OpenTokError, "Setting the layout failed. OpenTok server error."
      else
        raise OpenTokArchiveError, "Setting the layout failed."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def forceDisconnect(session_id, connection_id)
      response = self.class.delete("/v2/project/#{@api_key}/session/#{session_id}/connection/#{connection_id}", {
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 204
        response
      when 400
        raise ArgumentError, "Force disconnect failed. Connection ID #{connection_id} or Session ID #{session_id} is invalid"
      when 403
        raise OpenTokAuthenticationError, "You are not authorized to forceDisconnect, check your authentication credentials or token type is non-moderator"
      when 404
        raise OpenTokConnectionError, "The client specified by the connection ID: #{connection_id} is not connected to the session"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def signal(session_id, connection_id, opts)
      opts.extend(HashExtensions)
      connectionPath = connection_id.to_s.empty? ? "" : "/connection/#{connection_id}"
      url = "/v2/project/#{@api_key}/session/#{session_id}#{connectionPath}/signal"
      response = self.class.post(url, {
          :body => opts.camelize_keys!.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 204
        response
      when 400
        raise ArgumentError, "One of the signal properties — data, type, sessionId or connectionId — is invalid."
      when 403
        raise OpenTokAuthenticationError, "You are not authorized to send the signal. Check your authentication credentials."
      when 404
        raise OpenTokError, "The client specified by the connectionId property is not connected to the session."
      when 413
        raise OpenTokError, "The type string exceeds the maximum length (128 bytes), or the data string exceeds the maximum size (8 kB)."
      else
        raise OpenTokError, "The signal could not be send."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def dial(session_id, token, sip_uri, opts)
      opts.extend(HashExtensions)
      body = { "sessionId" => session_id,
               "token" => token,
               "sip" => { "uri" => sip_uri }.merge(opts.camelize_keys!)
      }

      response = self.class.post("/v2/project/#{@api_key}/dial", {
        :body => body.to_json,
        :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while dialing a SIP session. API Key: #{@api_key}"
      when 404
        raise OpenTokSipError, "The SIP session could not be dialed. The Session ID does not exist: #{session_id}"
      else
        raise OpenTokSipError, "The SIP session could not be dialed"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def info_stream(session_id, stream_id)
      streamId = stream_id.to_s.empty? ? '' : "/#{stream_id}"
      url = "/v2/project/#{@api_key}/session/#{session_id}/stream#{streamId}"
      response = self.class.get(url,
                                headers: generate_headers('Content-Type' => 'application/json'))
      case response.code
      when 200
        response
      when 400
        raise ArgumentError, 'Invalid request. You did not pass in a valid session ID or stream ID.'
      when 403
        raise OpenTokAuthenticationError, 'Check your authentication credentials. You passed in an invalid OpenTok API key.'
      when 408
        raise ArgumentError, 'You passed in an invalid stream ID.'
      when 500
        raise OpenTokError, 'OpenTok server error.'
      else
        raise OpenTokError, 'Could not fetch the stream information.'
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def layout_streams(session_id, opts)
      opts.extend(HashExtensions)
      response = self.class.put("/v2/project/#{@api_key}/session/#{session_id}/stream", {
          :body => opts.camelize_keys!.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokStreamLayoutError, "Setting the layout failed. The request was invalid or invalid layout options were given."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed. API Key: #{@api_key}"
      when 500
        raise OpenTokError, "Setting the layout failed. OpenTok server error."
      else
        raise OpenTokStreamLayoutError, "Setting the layout failed."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def start_broadcast(session_id, opts)
      opts.extend(HashExtensions)
      body = { :sessionId => session_id }.merge(opts.camelize_keys!)
      response = self.class.post("/v2/project/#{@api_key}/broadcast", {
          :body => body.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokBroadcastError, "The broadcast could not be started. The request was invalid or invalid layout options or exceeded the limit of five simultaneous RTMP streams."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while starting a broadcast. API Key: #{@api_key}"
      when 409
        raise OpenTokBroadcastError, "The broadcast has already been started for this session."
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokBroadcastError, "The broadcast could not be started"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def get_broadcast(broadcast_id)
      response = self.class.get("/v2/project/#{@api_key}/broadcast/#{broadcast_id}", {
          :headers => generate_headers
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokBroadcastError, "The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while getting a broadcast. API Key: #{@api_key}"
      when 404
        raise OpenTokBroadcastError, "No matching broadcast found (with the specified ID)"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokBroadcastError, "Could not fetch broadcast information."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def stop_broadcast(broadcast_id)
      response = self.class.post("/v2/project/#{@api_key}/broadcast/#{broadcast_id}/stop", {
          :headers => generate_headers
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokBroadcastError, "The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while stopping a broadcast. API Key: #{@api_key}"
      when 404
        raise OpenTokBroadcastError, "No matching broadcast found (with the specified ID) or it is already stopped"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokBroadcastError, "The broadcast could not be stopped."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def layout_broadcast(broadcast_id, opts)
      opts.extend(HashExtensions)
      response = self.class.put("/v2/project/#{@api_key}/broadcast/#{broadcast_id}/layout", {
          :body => opts.camelize_keys!.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokBroadcastError, "The layout operation could not be performed. The request was invalid or invalid layout options."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed for broadcast layout. API Key: #{@api_key}"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokBroadcastError, "The broadcast layout could not be performed."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

  end
end
