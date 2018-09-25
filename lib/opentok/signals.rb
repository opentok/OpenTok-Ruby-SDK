module OpenTok
  #  A class for working with OpenTok signals.
  class Signals
    # @private
    def initialize(client)
      @client = client
    end

    # Sends signals on an OpenTok session.
    #
    # Clients must be actively connected to the OpenTok session for you to successfully send
    # signals.
    #
    # You can send a signal to all valid connections in a session or to a specific connection of that
    # session.
    #
    # For more information on signaling, see the
    # {https://tokbox.com/developer/rest/#send_signal} programming guide.
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [Hash] options  A hash with the keys 'type' and 'data'.
    # @option options [String] :type This is the type of the signal. You can use this
    # field to group and filter signals. It is a property of the Signal object.
    # @option options [String] :data This is the data within the signal or the payload.
    # Contains main information to be sent in the signal. It is a property of the Signal object.
    # @option options [String] :connId When a connId is specified only that connection recieves a signal.
    #
    # @raise [OpenTokSignalingError] Signaling failed due to invalid properties.
    # @raise [OpenTokSignalingError] You are not authorized to send the signal. Check your authentication credentials.
    # @raise [OpenTokArchiveError] The client specified by the connId property is not connected to the session.
    # @raise [OpenTokArchiveError] The type string exceeds the maximum length (128 bytes), or the data string exceeds the maximum size (8 kB).
    def send(session_id, connectionId = "", options = {})
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      response = @client.signal(session_id, connectionId, options)
      (200..300).include? response.code
    end

  end
end