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

  end
end