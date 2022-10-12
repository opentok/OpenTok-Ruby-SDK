require "active_support/inflector"

module OpenTok
  # Represents a live streaming broadcast of an OpenTok session.
  # See {https://tokbox.com/developer/guides/broadcast/live-streaming/ Live streaming broadcasts}.
  #
  # @attr [string] id
  #   The broadcast ID.
  #
  # @attr [string] session_id
  #   The session ID of the OpenTok session associated with this broadcast.
  #
  # @attr [string] project_id
  #   The API key associated with the broadcast.
  #
  # @attr [int] created_at
  #   The time at which the broadcast was created, in milliseconds since the UNIX epoch.
  #
  # @attr [int] updated_at
  #   For this start method, this timestamp matches the createdAt timestamp.
  #
  # @attr [string] resolution
  #   The resolution of the broadcast: either "640x480" (SD landscape, the default), "1280x720" (HD landscape),
  #   "1920x1080" (FHD landscape), "480x640" (SD portrait), "720x1280" (HD portrait), or "1080x1920" (FHD portrait).
  #   You may want to use a portrait aspect ratio for broadcasts that include video streams from mobile devices (which often use the portrait aspect ratio).
  #   This property is optional.
  #
  # @attr [string] streamMode
  #   Whether streams included in the broadcast are selected automatically ("auto", the default) or manually ("manual").
  #
  # @attr [Hash] broadcastUrls is defined as follows:
  #   This object defines the types of broadcast streams you want to start (both HLS and RTMP).
  #   You can include HLS, RTMP, or both as broadcast streams. If you include RTMP streaming,
  #   you can specify up to five target RTMP streams (or just one).
  #   The (<code>:hls</code>)  property is set  to an empty [Hash] object. The HLS URL is returned in the response.
  #   The (<code>:rtmp</code>)  property is set  to an [Array] of Rtmp [Hash] properties.
  #   For each RTMP stream, specify (<code>:serverUrl</code>) for the RTMP server URL,
  #   (<code>:streamName</code>) such as the YouTube Live stream name or the Facebook stream key),
  #   and (optionally) (<code>:id</code>), a unique ID for the stream.
  #
  # @attr [string] status The status of the RTMP stream.
  #     * "connecting" --  The OpenTok platform is in the process of connecting to the remote RTMP server.
  #                        This is the initial state, and it is the status if you start when there are no streams published in the session.
  #                        It changes to "live" when there are streams (or it changes to one of the other states).
  #     * "live --         The OpenTok platform has successfully connected to the remote RTMP server, and the media is streaming.
  #     * "offline" --     The OpenTok platform could not connect to the remote RTMP server. This is due to an unreachable server or an error in the RTMP handshake. Causes include rejected RTMP connections, non-existing RTMP applications, rejected stream names, authentication errors, etc. Check that the server is online, and that you have provided the correct server URL and stream name.
  #     * "error" --       There is an error in the OpenTok platform.
  class Broadcast

    # @private
    def initialize(interface, json)
      @interface = interface
      # TODO: validate json fits schema
      @json = json
    end

    # A JSON-encoded string representation of the broadcast.
    def to_json
      @json.to_json
    end

    # Stops the OpenTok broadcast.
    def stop
      # TODO: validate returned json fits schema
      @json = @interface.stop @json['id']
    end

    # Sets the layout of the OpenTok broadcast.
    #
    # You can dynamically change the layout type of a broadcast while it is being broadcast.
    # For more information, see
    # {https://tokbox.com/developer/guides/broadcast/live-streaming/#configuring-video-layout-for-opentok-live-streaming-broadcasts Configuring video layout for OpenTok live streaming broadcasts}.
    #
    # @option options [String] :type
    #   The layout type. Set this to "bestFit", "pip", "verticalPresentation",
    #   "horizontalPresentation", "focus", or "custom".
    #
    # @option options [String] :stylesheet
    #   The stylesheet for a custom layout. Set this parameter
    #   if you set <code>type</code> to <code>"custom"</code>. Otherwise, leave it undefined.
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
    # Refer to {https://tokbox.com/developer/rest/#change_composed_archive_layout}

    def layout(opts = {})
      # TODO: validate returned json fits schema
      @json = @interface.layout(@json['id'], opts)
    end

    # Adds a stream to currently running broadcast that was started with the
    # streamMode set to "manual". For a description of the feature, see
    # {https://tokbox.com/developer/rest/#selecting-broadcast-streams}.
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
    # @raise [OpenTokBroadcastError]
    #   The streamMode for the broadcast is not set to "manual".
    #
    # You can call the method repeatedly with add_stream set to the same stream ID, to
    # toggle the stream's audio or video in the broadcast. If you set both has_audio and
    # has_video to false, you will get error response.
    def add_stream(stream_id, opts = {})
      raise OpenTokBroadcastError, "stream_mode must be manual in order to add a stream" unless @json['streamMode'] == 'manual'
      @interface.add_stream(@json['id'], stream_id, opts)
    end

    # Removes a stream to currently running broadcast that was started with the
    # streamMode set to "manual". For a description of the feature, see
    # {https://tokbox.com/developer/rest/#selecting-broadcast-streams}.
    #
    # @param [String] stream_id
    #   The ID for the stream to be removed from the broadcast
    #
    # @raise [OpenTokBroadcastError]
    #   The streamMode for the broadcast is not set to "manual".
    def remove_stream(stream_id)
      raise OpenTokBroadcastError, "stream_mode must be manual in order to add a stream" unless @json['streamMode'] == 'manual'
      @interface.remove_stream(@json['id'], stream_id)
    end

    # @private ignore
    def method_missing(method, *args, &block)
      camelized_method = method.to_s.camelize(:lower)
      if @json.has_key? camelized_method and args.empty?
        # TODO: convert create_time method call to a Time object
        if camelized_method == 'outputMode'
          @json[camelized_method].to_sym
        else
          @json[camelized_method]
        end
      else
        super method, *args, &block
      end
    end
  end
end
