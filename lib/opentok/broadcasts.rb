require "opentok/client"
require "opentok/broadcast"


module OpenTok
  # A class for working with OpenTok live streaming broadcasts.
  # See {https://tokbox.com/developer/guides/broadcast/live-streaming/ Live streaming broadcasts}.
  class Broadcasts

    # @private
    def initialize(client)
      @client = client
    end

    # Starts a live streaming broadcast of an OpenTok session.
    #
    # Clients must be actively connected to the OpenTok session for you to successfully start
    # a broadcast.
    #
    # This broadcasts the session to an HLS (HTTP live streaming) or to RTMP streams.
    #
    # @param [String] session_id The session ID of the OpenTok session to broadcast.
    #
    # @param [Hash] options A hash defining options for the broadcast.
    #
    # @option options [Hash] :layout Specify this to assign the initial layout type for
    #   the broadcast. This is a hash containing three keys:
    #   <code>:type</code>, <code>:stylesheet<code> and <code>:screenshare_type</code>.
    #   Valid values for <code>:type</code> are "bestFit" (best fit), "custom" (custom),
    #    "horizontalPresentation" (horizontal presentation),
    #   "pip" (picture-in-picture), and "verticalPresentation" (vertical presentation)).
    #   If you specify a "custom" layout type, set the <code>:stylesheet</code> key to the
    #   stylesheet (CSS). (For other layout types, do not set the <code>:stylesheet</code> key.)
    #   Valid values for <code>:screenshare_type</code> are "bestFit", "pip",
    #   "verticalPresentation", "horizontalPresentation". This property is optional.
    #   If it is specified, then the <code>:type</code> property **must** be set to "bestFit".
    #   If you do not specify an initial layout type, the broadcast uses the best fit
    #   layout type.
    #
    # @option options [int] maxDuration
    #   The maximum duration for the broadcast, in seconds. The broadcast will automatically stop when
    #   the maximum duration is reached. You can set the maximum duration to a value from 60 (60 seconds) to 36000 (10 hours).
    #   The default maximum duration is 4 hours (14,400 seconds).
    #
    # @option options [Hash] outputs
    #   This object defines the types of broadcast streams you want to start (both HLS and RTMP).
    #   You can include HLS, RTMP, or both as broadcast streams. If you include RTMP streaming,
    #   you can specify up to five target RTMP streams (or just one).
    #   The (<code>:hls</code>) property is set  to an empty [Hash] object. The HLS URL is returned in the response.
    #   The (<code>:rtmp</code>)  property is set  to an [Array] of Rtmp [Hash] properties.
    #   For each RTMP , specify (<code>:serverUrl</code>) for the RTMP server URL,
    #   (<code>:streamName</code>) such as the YouTube Live stream name or the Facebook stream key),
    #   and (optionally) (<code>:id</code>), a unique ID for the stream.
    #
    # @option options [string] resolution
    #   The resolution of the broadcast: either "640x480" (SD, the default) or "1280x720" (HD).
    #
    # @return [Broadcast] The broadcast object, which includes properties defining the broadcast,
    #   including the broadcast ID.
    #
    # @raise [OpenTokBroadcastError] The broadcast could not be started. The request was invalid or broadcast already started
    # @raise [OpenTokAuthenticationError] Authentication failed while starting an archive.
    #   Invalid API key.
    # @raise [OpenTokError] OpenTok server error.
    def create(session_id, options = {})
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      raise ArgumentError, "options cannot be empty" if options.empty?
      broadcast_json = @client.start_broadcast(session_id, options)
      Broadcast.new self, broadcast_json
    end

    # Gets a Broadcast object for the given broadcast ID.
    #
    # @param [String] broadcast_id The broadcast ID.
    #
    # @return [Broadcast] The broadcast object, which includes properties defining the broadcast.
    #
    # @raise [OpenTokBroadcastError] No matching broadcast found.
    # @raise [OpenTokAuthenticationError] Authentication failed.
    #   Invalid API key.
    # @raise [OpenTokError] OpenTok server error.
    def find(broadcast_id)
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      broadcast_json = @client.get_broadcast(broadcast_id.to_s)
      Broadcast.new self, broadcast_json
    end


    # Stops an OpenTok broadcast
    #
    # Note that broadcasts automatically stop after 120 minute
    #
    # @param [String] broadcast_id The broadcast ID.
    #
    # @return [Broadcast] The broadcast object, which includes properties defining the broadcast.
    #
    # @raise [OpenTokBroadcastError] The broadcast could not be stopped. The request was invalid.
    # @raise [OpenTokAuthenticationError] Authentication failed.
    #   Invalid API key.
    # @raise [OpenTokError] OpenTok server error.
    def stop(broadcast_id)
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      broadcast_json = @client.stop_broadcast(broadcast_id)
      Broadcast.new self, broadcast_json
    end

    # Dynamically alters the layout an OpenTok broadcast. For more information, see
    # For more information, see
    # {https://tokbox.com/developer/guides/broadcast/live-streaming/#configuring-video-layout-for-opentok-live-streaming-broadcasts Configuring video layout for OpenTok live streaming broadcasts}.
    #
    # @param [String] broadcast_id
    #   The broadcast ID.
    #
    # @option options [String] :type
    #   The layout type. Set this to "bestFit", "pip", "verticalPresentation",
    #   "horizontalPresentation", "focus", or "custom".
    #
    # @option options [String] :stylesheet
    #   The stylesheet for a custom layout. Set this parameter
    #   if you set <code>type</code> to <code>"custom"</code>. Otherwise, leave it undefined.
    #
    # @option options [String] :screenshare_type
    #   The screenshare layout type. Set this to "bestFit", "pip", "verticalPresentation" or
    #   "horizonalPresentation". If this is defined, then the <code>type</code> parameter
    #   must be set to <code>"bestFit"</code>.
    #
    # @raise [OpenTokBroadcastError]
    #   The broadcast layout could not be updated.
    #
    # @raise [OpenTokAuthenticationError]
    #   Authentication failed. Invalid API key or secret.
    #
    # @raise [OpenTokError]
    #   OpenTok server error.
    #
    # @raise [ArgumentError]
    #   The broadcast_id or options parameter is empty.
    #
    # @raise [ArgumentError]
    #   The "custom" type was specified without a stylesheet option.
    #
    # @raise [ArgumentError]
    #   A stylesheet was passed in for a type other than custom. Or an invalid type was passed in.
    #
    # @raise [ArgumentError]
    #   An invalid layout type was passed in.
    def layout(broadcast_id, options = {})
      raise ArgumentError, "option parameter is empty" if options.empty?
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      type = options[:type]
      raise ArgumentError, "custom type must have a stylesheet" if (type.eql? "custom") && (!options.key? :stylesheet)
      valid_non_custom_layouts = ["bestFit","horizontalPresentation","pip", "verticalPresentation", ""]
      valid_non_custom_type = valid_non_custom_layouts.include? type
      raise ArgumentError, "type is not valid" if !valid_non_custom_type && !(type.eql? "custom")
      raise ArgumentError, "stylesheet not needed" if valid_non_custom_type and options.key? :stylesheet
      raise ArgumentError, "screenshare_type is not valid" if options[:screenshare_type] && !valid_non_custom_layouts.include?(options[:screenshare_type])
      raise ArgumentError, "type must be set to 'bestFit' if screenshare_type is defined" if options[:screenshare_type] && type != 'bestFit'
      response = @client.layout_broadcast(broadcast_id, options)
      (200..300).include? response.code
    end

    def add_stream(broadcast_id, stream_mode, options)
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      raise ArgumentError, "stream_mode must be manual in order to add a stream" unless stream_mode == 'manual'
      raise ArgumentError, "option parameter is empty" if options.empty?
      add_stream = options[:add_stream]
      raise ArgumentError, "add_stream not provided" if add_stream.to_s.empty?
      if options.has_key?(:has_audio) && options.has_key?(:has_video)
        has_audio = options[:has_audio]
        has_video = options[:has_video]
        raise ArgumentError, "has_audio and has_video can't both be false" if audio_and_video_options_both_false?(has_audio, has_video)
      end

      @client.select_streams_for_broadcast(broadcast_id, options)
    end

    def remove_stream(broadcast_id, stream_mode, options)
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      raise ArgumentError, "stream_mode must be manual in order to add a stream" unless stream_mode == 'manual'
      raise ArgumentError, "option parameter is empty" if options.empty?
      remove_stream = options[:remove_stream]
      raise ArgumentError, "remove_stream not provided" if add_stream.to_s.empty?

      @client.select_streams_for_broadcast(broadcast_id, options)
    end

    private

    def audio_and_video_options_both_false?(has_audio, has_video)
      has_audio == false && has_video == false
    end

  end
end
