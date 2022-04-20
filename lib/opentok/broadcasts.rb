require "opentok/client"
require "opentok/broadcast"
require "opentok/broadcast_list"

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
    # @option options [Hash] outputs (Required)
    #   This object defines the types of broadcast streams you want to start (both HLS and RTMP).
    #   You can include HLS, RTMP, or both as broadcast streams. If you include RTMP streaming,
    #   you can specify up to five target RTMP streams (or just one).
    #
    #   For multiple RTMP streams, the (<code>:rtmp</code>) property is set to an [Array] of Rtmp [Hash] objects.
    #   For each RTMP hash, specify (<code>:serverUrl</code>) for the RTMP server URL,
    #   (<code>:streamName</code>) such as the YouTube Live stream name or the Facebook stream key),
    #   and (optionally) (<code>:id</code>), a unique ID for the stream. If you specify an ID, it will be
    #   included in the (<code>broadcast_json</code>) response from the Client#start_broadcast method call,
    #   and is also available in the (<code>broadcast_json</code>) response from the Broadcasts#find method.
    #   TokBox streams the session to each RTMP URL you specify. Note that OpenTok live streaming
    #   supports RTMP and RTMPS.
    #   If you need to support only one RTMP URL, you can set a Rtmp [Hash] object (instead of an array of
    #   objects) for the (<code>:rtmp</code>) property value in the (<code>:outputs</code>) [Hash].
    #
    #   For HLS, the (<code>:hls</code>) property in the (<code>:outputs</code>) [Hash] is set to a HLS [Hash]
    #   object. This object includes the following optional properties:
    #   - (<code>:dvr</code>) (Boolean).  Whether to enable DVR functionality
    #     { https://tokbox.com/developer/guides/broadcast/live-streaming/#dvr } (rewinding, pausing, and resuming)
    #     in players that support it (true), or not (false, the default). With DVR enabled, the HLS URL will
    #     include a ?DVR query string appended to the end.
    #   - (<code>:lowLatency</code>) (Boolean). Whether to enable low-latency mode for the HLSstream.
    #     { https://tokbox.com/developer/guides/broadcast/live-streaming/#low-latency }
    #     Some HLS players do not support low-latency mode. This feature is incompatible with DVR mode HLS
    #     broadcasts (both can't be set to true). This is a beta feature.
    #   The HLS URL is included in the (<code>broadcast_json</code>) response from the Client#start_broadcast
    #   method call, and is also available in the (<code>broadcast_json</code>) response from the
    #  Broadcasts#find method.
    #
    # @option options [string] resolution
    #   The resolution of the broadcast: either "640x480" (SD, the default) or "1280x720" (HD).
    #
    # @option options [String] :streamMode (Optional) Whether streams included in the broadcast are selected
    #   automatically ("auto", the default) or manually ("manual"). When streams are selected automatically ("auto"),
    #   all streams in the session can be included in the broadcast. When streams are selected manually ("manual"),
    #   you specify streams to be included based on calls to this REST method
    #   { https://tokbox.com/developer/rest/#selecting-broadcast-streams }. You can specify whether a
    #   stream's audio, video, or both are included in the broadcast.
    #   For both automatic and manual modes, the broadcast composer includes streams based
    #   on stream prioritization rules { https://tokbox.com/developer/guides/archive-broadcast-layout/#stream-prioritization-rules }.
    #   Important: this feature is currently available in the Standard environment only.
    #
    # @return [Broadcast] The broadcast object, which includes properties defining the broadcast,
    #   including the broadcast ID.
    #
    # @raise [OpenTokBroadcastError] The broadcast could not be started. The request was invalid or broadcast already started
    # @raise [OpenTokAuthenticationError] Authentication failed while starting an broadcast.
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

    # Returns a BroadcastList, which is an array of broadcasts that are completed and in-progress,
    # for your API key.
    #
    # @param [Hash] options  A hash with keys defining which range of broadcasts to retrieve.
    # @option options [integer] :offset Optional. The index offset of the first broadcast. 0 is offset
    #   of the most recently started broadcast. 1 is the offset of the broadcast that started prior to
    #   the most recent broadcast. If you do not specify an offset, 0 is used.
    # @option options [integer] :count Optional. The number of broadcasts to be returned. The maximum
    #   number of broadcasts returned is 1000.
    # @option options [String] :session_id Optional. The session ID that broadcasts belong to.
    # https://tokbox.com/developer/rest/#list_broadcasts
    #
    # @return [BroadcastList] An BroadcastList object, which is an array of Broadcast objects.
    def all(options = {})
      raise ArgumentError, "Limit is invalid" unless options[:count].nil? || (0..1000).include?(options[:count])

      broadcast_list_json = @client.list_broadcasts(options[:offset], options[:count], options[:sessionId])
      BroadcastList.new self, broadcast_list_json
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

    # Adds a stream to currently running broadcast that was started with the
    # streamMode set to "manual". For a description of the feature, see
    # {https://tokbox.com/developer/rest/#selecting-broadcast-streams}.
    #
    # @param [String] broadcast_id
    #   The broadcast ID.
    #
    # @param [String] stream_id
    #   The ID for the stream to be added to the broadcast
    #
    # @option opts [true, false] :has_audio
    #   (Boolean, optional) — Whether the broadcast should include the stream's
    #   audio (true, the default) or not (false).
    #
    # @option opts [true, false] :has_video
    #   (Boolean, optional) — Whether the broadcast should include the stream's
    #   video (true, the default) or not (false).
    #
    # You can call the method repeatedly with add_stream set to the same stream ID, to
    # toggle the stream's audio or video in the broadcast. If you set both has_audio and
    # has_video to false, you will get error response.
    #
    # @raise [ArgumentError]
    #   The broadcast_id parameter is empty.
    #
    # @raise [ArgumentError]
    #   The stream_id parameter is empty.
    #
    # @raise [ArgumentError]
    #   The has_audio and has_video properties of the options parameter are both set to "false"
    #
    def add_stream(broadcast_id, stream_id, options)
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      raise ArgumentError, "stream_id not provided" if stream_id.to_s.empty?
      if options.has_key?(:has_audio) && options.has_key?(:has_video)
        has_audio = options[:has_audio]
        has_video = options[:has_video]
        raise ArgumentError, "has_audio and has_video can't both be false" if audio_and_video_options_both_false?(has_audio, has_video)
      end
      options['add_stream'] = stream_id

      @client.select_streams_for_broadcast(broadcast_id, options)
    end

    # Removes a stream from a currently running broadcast that was started with the
    # streamMode set to "manual". For a description of the feature, see
    # {https://tokbox.com/developer/rest/#selecting-broadcast-streams}.
    #
    # @param [String] broadcast_id
    #   The broadcast ID.
    #
    # @param [String] stream_id
    #   The ID for the stream to be removed from the broadcast
    #
    # @raise [ArgumentError]
    #   The broadcast_id parameter id is empty.
    #
    # @raise [ArgumentError]
    #   The stream_id parameter is empty.
    #
    def remove_stream(broadcast_id, stream_id)
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      raise ArgumentError, "stream_id not provided" if stream_id.to_s.empty?
      options = {}
      options['remove_stream'] = stream_id

      @client.select_streams_for_broadcast(broadcast_id, options)
    end

    private

    def audio_and_video_options_both_false?(has_audio, has_video)
      has_audio == false && has_video == false
    end

  end
end
