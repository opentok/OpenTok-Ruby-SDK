module OpenTok
  #  A class for working with OpenTok signals.
  class Connections
    # @private
    def initialize(client)
      @client = client
    end

    # Force-disconnect a client from an OpenTok session.
    #
    # Clients must be actively connected to the OpenTok session for you to disconnect it
    #

    # For more information on signaling, see the
    # {https://tokbox.com/developer/rest/#forceDisconnect} programming guide.
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [String] connection_id The connection ID within the session.
    #
    # @raise [ArgumentError] connection_id or session_id is invalid.
    # @raise [OpenTokAuthenticationError] You are not authorized to send the signal. Check your authentication credentials.
    # @raise [OpenTokConnectionError] The client specified by the connId property is not connected to the session.
    #
    def forceDisconnect(session_id, connection_id )
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      raise ArgumentError, "connection_id not provided" if connection_id.to_s.empty?
      response = @client.forceDisconnect(session_id, connection_id)
      (200..300).include? response.code
    end

  end
end