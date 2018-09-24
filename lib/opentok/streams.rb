require "opentok/client"

module OpenTok
  #  A class for working with OpenTok signconnectionsals.
  class Streams
    # @private
    def initialize(client)
      @client = client
    end

    # Use this method to get information on an OpenTok stream (or all streams in a session).
    #
    # For example, you can call this method to get information about layout classes used by an OpenTok stream.
    # The layout classes define how the stream is displayed in the layout of a broadcast stream.
    # For more information, see Assigning{https://tokbox.com/developer/guides/broadcast/live-streaming/#assign-layout-classes-to-streams}
    # live streaming layout classes to OpenTok streams.
    #

    # For more information on getting stream information, see the
    # {https://tokbox.com/developer/rest/#get-stream-info} programming guide.
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [String] stream_id The stream ID within the session.
    #
    # @raise [ArgumentError] stream_id or session_id is invalid.
    # @raise [OpenTokAuthenticationError] You are not authorized to fetch the stream information. Check your authentication credentials.
    # @raise [OpenTokError] An OpenTok server error.
    #
    def info_stream(session_id, stream_id = '')
      raise ArgumentError, 'session_id not provided' if session_id.to_s.empty?
      response = @client.info_stream(session_id, stream_id)
      (200..300).include? response.code
    end

  end
end