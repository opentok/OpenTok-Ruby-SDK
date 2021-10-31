module OpenTok
  #  A class for working with OpenTok connections.
  class Connections
    # @private
    def initialize(client)
      @client = client
    end

    # Force a client to disconnect from an OpenTok session.
    #
    # A client must be actively connected to the OpenTok session for you to disconnect it.
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [String] connection_id The connection ID of the client in the session.
    #
    # @raise [ArgumentError] The connection_id or session_id is invalid.
    # @raise [OpenTokAuthenticationError] You are not authorized to disconnect the connection. Check your authentication credentials.
    # @raise [OpenTokConnectionError] The client specified by the connection_id  property is not connected to the session.
    #
    def forceDisconnect(session_id, connection_id )
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      raise ArgumentError, "connection_id not provided" if connection_id.to_s.empty?
      response = @client.forceDisconnect(session_id, connection_id)
      (200..300).include? response.code
    end

    # Force a specific client connected to an OpenTok session to mute itself.
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [String] stream_id The stream ID of the client in the session.

    def force_mute_stream(session_id, stream_id)
      response = @client.force_mute_stream(session_id, stream_id)
    end

    # Force all clients connected to an OpenTok session to mute themselves.
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [Hash] opts An optional hash defining options for muting action. For example:
    # @option opts [true, false] :active Whether streams published after this call, in
    # addition to the current streams in the session, should be muted (true) or not (false).
    # @option opts [Array] :excluded_streams The stream IDs for streams that should not be muted.
    # This is an optional property. If you omit this property, all streams in the session will be muted.
    # @example
    # {
    #   "active": true,
    #   "excluded_streams": [
    #     "excludedStreamId1",
    #     "excludedStreamId2"
    #   ]
    # }

    def force_mute_session(session_id, opts = {})
      response = @client.force_mute_session(session_id, opts)
    end

  end
end
