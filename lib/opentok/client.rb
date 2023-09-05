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

    # TODO: expose a setting for http debugging for developers
    # debug_output $stdout

    attr_accessor :api_key, :api_secret, :api_url, :ua_addendum, :timeout_length

    def initialize(api_key, api_secret, api_url, ua_addendum='', opts={})
      self.class.base_uri api_url
      self.class.headers({
        "User-Agent" => "OpenTok-Ruby-SDK/#{VERSION}" + "-Ruby-Version-#{RUBY_VERSION}-p#{RUBY_PATCHLEVEL}" + (ua_addendum ? " #{ua_addendum}" : "")
      })
      @api_key = api_key
      @api_secret = api_secret
      @timeout_length = opts[:timeout_length] || 2
      self.class.open_timeout @timeout_length
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

    # Archives methods

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

    def select_streams_for_archive(archive_id, opts)
      opts.extend(HashExtensions)
      body = opts.camelize_keys!
      response = self.class.patch("/v2/project/#{@api_key}/archive/#{archive_id}/streams", {
          :body => body.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 204
        response
      when 400
        raise OpenTokArchiveError, "The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed. API Key: #{@api_key}"
      when 404
        raise OpenTokArchiveError, "No matching archive found with the specified ID: #{archive_id}"
      when 405
        raise OpenTokArchiveError, "The archive was started with streamMode set to 'auto', which does not support stream manipulation."
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokArchiveError, "The archive streams could not be updated."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    # Broadcasts methods

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

    def list_broadcasts(offset, count, session_id)
      query = Hash.new
      query[:offset] = offset unless offset.nil?
      query[:count] = count unless count.nil?
      query[:sessionId] = session_id unless session_id.nil?
      response = self.class.get("/v2/project/#{@api_key}/broadcast", {
        :query => query.empty? ? nil : query,
        :headers => generate_headers,
      })
      case response.code
      when 200
        response
      when 403
        raise OpenTokAuthenticationError,
          "Authentication failed while retrieving broadcasts. API Key: #{@api_key}"
      else
        raise OpenTokBroadcastError, "The broadcasts could not be retrieved."
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

    def select_streams_for_broadcast(broadcast_id, opts)
      opts.extend(HashExtensions)
      body = opts.camelize_keys!
      response = self.class.patch("/v2/project/#{@api_key}/broadcast/#{broadcast_id}/streams", {
          :body => body.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 204
        response
      when 400
        raise OpenTokBroadcastError, "The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed. API Key: #{@api_key}"
      when 404
        raise OpenTokBroadcastError, "No matching broadcast found with the specified ID: #{broadcast_id}"
      when 405
        raise OpenTokBroadcastError, "The broadcast was started with streamMode set to 'auto', which does not support stream manipulation."
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokBroadcastError, "The broadcast streams could not be updated."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    # Captions methods

    def start_live_captions(session_id, token, options)
      options.extend(HashExtensions)
      body = { "sessionId" => session_id,
               "token" => token,
              }.merge(options.camelize_keys!)

      response = self.class.post("/v2/project/#{@api_key}/captions", {
        :body => body.to_json,
        :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 202
        response
      when 400
        raise OpenTokCaptionsError, "The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while starting captions. API Key: #{@api_key}"
      when 409
        raise OpenTokCaptionsError, "Live captions have already started for this OpenTok Session: #{session_id}"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokCaptionsError, "Captions could not be started"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def stop_live_captions(captions_id)
      response = self.class.post("/v2/project/#{@api_key}/captions/#{captions_id}/stop", {
        :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 202
        response
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while starting captions. API Key: #{@api_key}"
      when 404
        raise OpenTokCaptionsError, "No matching captions_id was found: #{captions_id}"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokCaptionsError, "Captions could not be stopped"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    # Connections methods

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

    # Renders methods

    def start_render(session_id, opts)
      opts.extend(HashExtensions)
      body = { :sessionId => session_id }.merge(opts.camelize_keys!)
      response = self.class.post("/v2/project/#{@api_key}/render", {
          :body => body.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 202
        response
      when 400
        raise OpenTokRenderError, "The render could not be started. The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while starting a render. API Key: #{@api_key}"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokRenderError, "The render could not be started"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def get_render(render_id)
      response = self.class.get("/v2/project/#{@api_key}/render/#{render_id}", {
          :headers => generate_headers
      })
      case response.code
      when 200
        response
      when 400
        raise OpenTokRenderError, "The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while getting a render. API Key: #{@api_key}"
      when 404
        raise OpenTokRenderError, "No matching render found (with the specified ID)"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokRenderError, "Could not fetch render information."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def stop_render(render_id)
      response = self.class.delete("/v2/project/#{@api_key}/render/#{render_id}", {
          :headers => generate_headers
      })
      case response.code
      when 204
        response
      when 400
        raise OpenTokRenderError, "The request was invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed while stopping a render. API Key: #{@api_key}"
      when 404
        raise OpenTokRenderError, "No matching render found (with the specified ID) or it is already stopped"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokRenderError, "The render could not be stopped."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def list_renders(offset, count)
      query = Hash.new
      query[:offset] = offset unless offset.nil?
      query[:count] = count unless count.nil?
      response = self.class.get("/v2/project/#{@api_key}/render", {
        :query => query.empty? ? nil : query,
        :headers => generate_headers,
      })
      case response.code
      when 200
        response
      when 403
        raise OpenTokAuthenticationError,
          "Authentication failed while retrieving renders. API Key: #{@api_key}"
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokRenderError, "The renders could not be retrieved."
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    # Sip methods

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

    def play_dtmf_to_connection(session_id, connection_id, dtmf_digits)
      body = { "digits" => dtmf_digits }

      response = self.class.post("/v2/project/#{@api_key}/session/#{session_id}/connection/#{connection_id}/play-dtmf", {
        :body => body.to_json,
        :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise ArgumentError, "One of the properties — dtmf_digits #{dtmf_digits} or session_id #{session_id} — is invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed. This can occur if you use an invalid OpenTok API key or an invalid JSON web token. API Key: #{@api_key}"
      when 404
        raise OpenTokError, "The specified session #{session_id} does not exist or the client specified by the #{connection_id} property is not connected to the session."
      else
        raise OpenTokError, "An error occurred when attempting to play DTMF digits to the session"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def play_dtmf_to_session(session_id, dtmf_digits)
      body = { "digits" => dtmf_digits }

      response = self.class.post("/v2/project/#{@api_key}/session/#{session_id}/play-dtmf", {
        :body => body.to_json,
        :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise ArgumentError, "One of the properties — dtmf_digits #{dtmf_digits} or session_id #{session_id} — is invalid."
      when 403
        raise OpenTokAuthenticationError, "Authentication failed. This can occur if you use an invalid OpenTok API key or an invalid JSON web token. API Key: #{@api_key}"
      when 404
        raise OpenTokError, "The specified session does not exist. Session ID: #{session_id}"
      else
        raise OpenTokError, "An error occurred when attempting to play DTMF digits to the session"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    # Streams methods

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

    def force_mute_stream(session_id, stream_id)
      response = self.class.post("/v2/project/#{@api_key}/session/#{session_id}/stream/#{stream_id}/mute", {
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise ArgumentError, "Force mute failed. Stream ID #{stream_id} or Session ID #{session_id} is invalid"
      when 403
        raise OpenTokAuthenticationError, "Authentication failed. API Key: #{@api_key}"
      when 404
        raise OpenTokConnectionError, "Either Stream ID #{stream_id} or Session ID #{session_id} is invalid"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    def force_mute_session(session_id, opts)
      opts.extend(HashExtensions)
      body = opts.camelize_keys!
      response = self.class.post("/v2/project/#{@api_key}/session/#{session_id}/mute", {
          :body => body.to_json,
          :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise ArgumentError, "Force mute failed. The request could not be processed due to a bad request"
      when 403
        raise OpenTokAuthenticationError, "Authentication failed. API Key: #{@api_key}"
      when 404
        raise OpenTokConnectionError, "Session ID #{session_id} is invalid"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end

    # Signals methods

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

    # WebSocket methods

    def connect_websocket(session_id, token, websocket_uri, opts)
      opts.extend(HashExtensions)
      body = { "sessionId" => session_id,
               "token" => token,
               "websocket" => { "uri" => websocket_uri }.merge(opts.camelize_keys!)
      }

      response = self.class.post("/v2/project/#{@api_key}/connect", {
        :body => body.to_json,
        :headers => generate_headers("Content-Type" => "application/json")
      })
      case response.code
      when 200
        response
      when 400
        raise ArgumentError, "One of the properties is invalid."
      when 403
        raise OpenTokAuthenticationError, "You are not authorized to start the call, check your authentication information."
      when 409
        raise OpenTokWebSocketError, "Conflict. Only routed sessions are allowed to initiate Connect Calls."
      when 500
        raise OpenTokError, "OpenTok server error."
      else
        raise OpenTokWebSocketError, "The WebSocket could not be connected"
      end
    rescue StandardError => e
      raise OpenTokError, "Failed to connect to OpenTok. Response code: #{e.message}"
    end
  end
end
