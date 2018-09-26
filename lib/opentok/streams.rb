require 'opentok/client'
require 'opentok/stream'


module OpenTok
  #  A class for working with OpenTok signconnectionsals.
  class Streams
    # @private
    def initialize(client)
      @client = client
    end

    # Use this method to get information on an OpenTok stream.
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
    # @return [Stream] The Stream object.
    # @raise [ArgumentError] stream_id or session_id is invalid.
    # @raise [OpenTokAuthenticationError] You are not authorized to fetch the stream information. Check your authentication credentials.
    # @raise [OpenTokError] An OpenTok server error.
    #
    def find(session_id, stream_id)
      raise ArgumentError, 'session_id not provided' if session_id.to_s.empty?
      raise ArgumentError, 'stream_id not provided' if session_id.to_s.empty?
      stream_json = @client.info_stream(session_id, stream_id)
      Stream.new stream_json
    end

    # Use this method to get information on all OpenTok stream.
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
    # @return [StreamList] The StreamList of Stream objects
    # @raise [ArgumentError] stream_id or session_id is invalid.
    # @raise [OpenTokAuthenticationError] You are not authorized to fetch the stream information. Check your authentication credentials.
    # @raise [OpenTokError] An OpenTok server error.
    #
    def all(session_id)
      raise ArgumentError, 'session_id not provided' if session_id.to_s.empty?
      response_json = @client.info_stream(session_id, '')
      StreamList.new response_json
    end

    # Use this method to set the layout of a composed (archive or broadcast) OpenTok stream.
    #
    # For example, you can call this method to get information about layout classes used by an OpenTok stream.
    # The layout classes define how the stream is displayed in the layout of a broadcast or archive stream.
    # For more information, see Assigning{https://tokbox.com/developer/guides/broadcast/live-streaming/#assign-layout-classes-to-streams}
    # live streaming layout classes to OpenTok streams.
    #
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [Hash] options  A hash with one key `items` and value as array of objects having stream_id and layoutClassList
    # For more information, see Layout{https://tokbox.com/developer/rest/#change-stream-layout-classes-composed}
    # @raise [ArgumentError] session_id is invalid.
    # @raise [OpenTokAuthenticationError] You are not authorized to fetch the stream information. Check your authentication credentials.
    # @raise [OpenTokStreamLayoutError] The layout operation could not be performed due to wrong layout values.
    # @raise [OpenTokError] An OpenTok server error.
    #
    def layout(session_id, opts)
      raise ArgumentError, 'session_id not provided' if session_id.to_s.empty?
      raise ArgumentError, 'opts is empty' if opts.empty?
      response = @client.layout_streams(session_id, opts)
      (200..300).include? response.code
    end

  end
end