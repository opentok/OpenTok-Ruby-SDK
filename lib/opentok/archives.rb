require "opentok/client"
require "opentok/archive"
require "opentok/archive_list"

module OpenTok
  # A class for working with OpenTok archives.
  class Archives

    # @private
    def initialize(client)
      @client = client
    end

    # Starts archiving an OpenTok session.
    #
    # Clients must be actively connected to the OpenTok session for you to successfully start
    # recording an archive.
    #
    # You can only record one archive at a time for a given session. You can only record archives
    # of sessions that use the OpenTok Media Router (sessions with the media mode set to routed);
    # you cannot archive sessions with the media mode set to relayed.
    #
    # For more information on archiving, see the
    # {https://tokbox.com/opentok/tutorials/archiving OpenTok archiving} programming guide.
    #
    # @param [String] session_id The session ID of the OpenTok session to archive.
    # @param [Hash] options  A hash with the keys 'name', 'has_audio', 'has_video',
    #   and 'output_mode'.
    # @option options [String] :name This is the name of the archive. You can use this name
    #   to identify the archive. It is a property of the Archive object, and it is a property
    #   of archive-related events in the OpenTok client SDKs.
    # @option options [true, false] :has_audio Whether the archive will include an audio track
    #   (<code>true</code>) or not <code>false</code>). The default value is <code>true</code>
    #   (an audio track is included). If you set both  <code>has_audio</code> and
    #   <code>has_video</code> to <code>false</code>, the call to the <code>create()</code>
    #   method results in an error.
    # @option options [true, false] :has_video Whether the archive will include a video track
    #   (<code>true</code>) or not <code>false</code>). The default value is <code>true</code>
    #   (a video track is included). If you set both  <code>has_audio</code> and
    #   <code>has_video</code> to <code>false</code>, the call to the <code>create()</code>
    #   method results in an error.
    # @option options [String] :multi_archive_tag (Optional) Set this to support recording multiple archives for the same session simultaneously. 
    #    Set this to a unique string for each simultaneous archive of an ongoing session. You must also set this option when manually starting an archive 
    #    that is {https://tokbox.com/developer/guides/archiving/#automatic automatically archived}. Note that the `multiArchiveTag` value is not included
    #    in the response for the methods to {https://tokbox.com/developer/rest/#listing_archives list archives} and 
    #    {https://tokbox.com/developer/rest/#retrieve_archive_info retrieve archive information}. If you do not specify a unique `multi_archive_tag`, 
    #    you can only record one archive at a time for a given session. 
    #    {https://tokbox.com/developer/guides/archiving/#simultaneous-archives See Simultaneous archives}.
    # @option options [String] :output_mode Whether all streams in the archive are recorded
    #     to a single file (<code>:composed</code>, the default) or to individual files
    #     (<code>:individual</code>). For more information on archiving and the archive file
    #     formats, see the {https://tokbox.com/opentok/tutorials/archiving OpenTok archiving}
    #     programming guide.
    # @option options [String] :resolution The resolution of the archive, either "640x480" (SD landscape,
    #  the default), "1280x720" (HD landscape), "1920x1080" (FHD landscape), "480x640" (SD portrait), "720x1280"
    #  (HD portrait), or "1080x1920" (FHD portrait). This property only applies to composed archives. If you set
    #  this property and set the outputMode property to "individual", a call to the method
    #  results in an error.
    # @option options [String] :stream_mode (Optional) Whether streams included in the archive are selected
    #   automatically ("auto", the default) or manually ("manual"). When streams are selected automatically ("auto"),
    #   all streams in the session can be included in the archive. When streams are selected manually ("manual"),
    #   you specify streams to be included based on calls to the {Archives#add_stream} method. You can specify whether a
    #   stream's audio, video, or both are included in the archive.
    #   In composed archives, in both automatic and manual modes, the archive composer includes streams based
    #   on {https://tokbox.com/developer/guides/archive-broadcast-layout/#stream-prioritization-rules stream prioritization rules}.
    #   Important: this feature is currently available in the Standard environment only.
    # @option options [Hash] :layout Specify this to assign the initial layout type for
    #   the archive. This applies only to composed archives. This is a hash containing three keys:
    #   <code>:type</code>, <code>:stylesheet<code> and <code>:screenshare_type</code>.
    #   Valid values for <code>:type</code> are "bestFit" (best fit), "custom" (custom),
    #    "horizontalPresentation" (horizontal presentation),
    #   "pip" (picture-in-picture), and "verticalPresentation" (vertical presentation)).
    #   If you specify a "custom" layout type, set the <code>:stylesheet</code> key to the
    #   stylesheet (CSS). (For other layout types, do not set the <code>:stylesheet</code> key.)
    #   Valid values for <code>:screenshare_type</code> are "bestFit", "pip",
    #   "verticalPresentation", "horizontalPresentation". This property is optional.
    #   If it is specified, then the <code>:type</code> property **must** be set to "bestFit".
    #   If you do not specify an initial layout type, the archive uses the best fit
    #   layout type. For more information, see
    #   {https://tokbox.com/developer/guides/archiving/layout-control.html Customizing
    #   the video layout for composed archives}.
    #
    # @return [Archive] The Archive object, which includes properties defining the archive,
    #   including the archive ID.
    #
    # @raise [OpenTokArchiveError] The archive could not be started. The request was invalid or
    #   the session has no connected clients.
    # @raise [OpenTokAuthenticationError] Authentication failed while starting an archive.
    #   Invalid API key.
    # @raise [OpenTokArchiveError] The archive could not be started. The session ID does not exist.
    # @raise [OpenTokArchiveError] The archive could not be started. The session could be
    #   peer-to-peer or the session is already being recorded.
    # @raise [OpenTokArchiveError] The archive could not be started.
    def create(session_id, options = {})
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      raise ArgumentError,
        "Resolution cannot be supplied for individual output mode" if options.key?(:resolution) and options[:output_mode] == :individual

      # normalize opts so all keys are symbols and only include valid_opts
      valid_opts = [
        :name,
        :has_audio,
        :has_video,
        :output_mode,
        :resolution,
        :layout,
        :multi_archive_tag,
        :stream_mode
      ]
      opts = options.inject({}) do |m,(k,v)|
        if valid_opts.include? k.to_sym
          m[k.to_sym] = v
        end
        m
      end

      archive_json = @client.start_archive(session_id, opts)
      Archive.new self, archive_json
    end

    # Gets an Archive object for the given archive ID.
    #
    # @param [String] archive_id The archive ID.
    #
    # @return [Archive] The Archive object.
    # @raise [OpenTokArchiveError] The archive could not be retrieved. The archive ID is invalid.
    # @raise [OpenTokAuthenticationError] Authentication failed while retrieving the archive.
    #   Invalid API key.
    # @raise [OpenTokArchiveError] The archive could not be retrieved.
    def find(archive_id)
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      archive_json = @client.get_archive(archive_id.to_s)
      Archive.new self, archive_json
    end

    # Returns an ArchiveList, which is an array of archives that are completed and in-progress,
    # for your API key.
    #
    # @param [Hash] options  A hash with keys defining which range of archives to retrieve.
    # @option options [integer] :offset Optional. The index offset of the first archive. 0 is offset
    #   of the most recently started archive. 1 is the offset of the archive that started prior to
    #   the most recent archive. If you do not specify an offset, 0 is used.
    # @option options [integer] :count Optional. The number of archives to be returned. The maximum
    #   number of archives returned is 1000.
    # @option options [String] :session_id Optional. The session ID that archives belong to. This is
    #   useful when listing multiple archives for an {https://tokbox.com/developer/guides/archiving/#automatic-archives automatically archived session}.
    #
    # @return [ArchiveList] An ArchiveList object, which is an array of Archive objects.
    def all(options = {})
      raise ArgumentError, "Limit is invalid" unless options[:count].nil? or (0..1000).include? options[:count]
      archive_list_json = @client.list_archives(options[:offset], options[:count], options[:sessionId])
      ArchiveList.new self, archive_list_json
    end

    # Stops an OpenTok archive that is being recorded.
    #
    # Archives automatically stop recording after 120 minutes or when all clients have disconnected
    # from the session being archived.
    #
    # @param [String] archive_id The archive ID of the archive you want to stop recording.
    #
    # @return [Archive] The Archive object corresponding to the archive being stopped.
    #
    # @raise [OpenTokArchiveError] The archive could not be stopped. The request was invalid.
    # @raise [OpenTokAuthenticationError] Authentication failed while stopping an archive.
    # @raise [OpenTokArchiveError] The archive could not be stopped. The archive ID does not exist.
    # @raise [OpenTokArchiveError] The archive could not be stopped. The archive is not currently
    #   recording.
    # @raise [OpenTokArchiveError] The archive could not be started.
    def stop_by_id(archive_id)
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      archive_json = @client.stop_archive(archive_id)
      Archive.new self, archive_json
    end

    # Deletes an OpenTok archive.
    #
    # You can only delete an archive which has a status of "available", "uploaded", or "deleted".
    # Deleting an archive removes its record from the list of archives. For an "available" archive,
    # it also removes the archive file, making it unavailable for download. For a "deleted"
    # archive, the archive remains deleted.
    #
    # @param [String] archive_id The archive ID of the archive you want to delete.
    #
    # @raise [OpenTokAuthenticationError] Authentication failed or an invalid archive ID was given.
    # @raise [OpenTokArchiveError] The archive could not be deleted. The status must be
    #   'available', 'deleted', or 'uploaded'.
    # @raise [OpenTokArchiveError] The archive could not be deleted.
    def delete_by_id(archive_id)
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      response = @client.delete_archive(archive_id)
      (200..300).include? response.code
    end

    # Sets the layout type for a composed archive. For a description of layout types, see
    # {https://tokbox.com/developer/guides/archiving/layout-control.html Customizing
    # the video layout for composed archives}.
    #
    # @param [String] archive_id
    #   The archive ID.
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
    # @raise [ArgumentError]
    #   The archive_id or options parameter is empty. Or the "custom"
    #   type was specified without a stylesheet option. Or a stylesheet was passed in for a
    #   type other than custom. Or an invalid type was passed in.
    #
    # @raise [OpenTokAuthenticationError]
    #   Authentication failed.
    #
    # @raise [ArgumentError]
    #   The archive_id or options parameter is empty.
    #
    # @raise [ArgumentError]
    #   The "custom" type was specified without a stylesheet option.
    #
    # @raise [ArgumentError]
    #   A stylesheet was passed in for a type other than custom. Or an invalid type was passed in.
    #
    # @raise [ArgumentError]
    #   An invalid layout type was passed in.
    #
    # @raise [OpenTokError]
    #   OpenTok server error.
    #
    # @raise [OpenTokArchiveError]
    #   Setting the layout failed.
    def layout(archive_id, options = {})
      raise ArgumentError, "option parameter is empty" if options.empty?
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      type = options[:type]
      raise ArgumentError, "custom type must have a stylesheet" if (type.eql? "custom") && (!options.key? :stylesheet)
      valid_non_custom_layouts = ["bestFit","horizontalPresentation","pip", "verticalPresentation", ""]
      valid_non_custom_type = valid_non_custom_layouts.include? type
      raise ArgumentError, "type is not valid" if !valid_non_custom_type && !(type.eql? "custom")
      raise ArgumentError, "type is not valid or stylesheet not needed" if valid_non_custom_type and options.key? :stylesheet
      raise ArgumentError, "screenshare_type is not valid" if options[:screenshare_type] && !valid_non_custom_layouts.include?(options[:screenshare_type])
      raise ArgumentError, "type must be set to 'bestFit' if screenshare_type is defined" if options[:screenshare_type] && type != 'bestFit'
      response = @client.layout_archive(archive_id, options)
      (200..300).include? response.code
    end

    # Adds a stream to currently running composed archive that was started with the
    # streamMode set to "manual". For a description of the feature, see
    # {https://tokbox.com/developer/rest/#selecting-archive-streams}.
    #
    # @param [String] archive_id
    #   The archive ID.
    #
    # @param [String] stream_id
    #   The ID for the stream to be added to the archive
    #
    # @option opts [true, false] :has_audio
    #   (Boolean, optional) — Whether the composed archive should include the stream's
    #   audio (true, the default) or not (false).
    #
    # @option opts [true, false] :has_video
    #   (Boolean, optional) — Whether the composed archive should include the stream's
    #   video (true, the default) or not (false).
    #
    # You can call the method repeatedly with add_stream set to the same stream ID, to
    # toggle the stream's audio or video in the archive. If you set both has_audio and
    # has_video to false, you will get error response.
    #
    # @raise [ArgumentError]
    #   The archive_id parameter is empty.
    #
    # @raise [ArgumentError]
    #   The stream_id parameter is empty.
    #
    # @raise [ArgumentError]
    #   The has_audio and has_video properties of the options parameter are both set to "false"
    #
    def add_stream(archive_id, stream_id, options)
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      raise ArgumentError, "stream_id not provided" if stream_id.to_s.empty?
      if options.has_key?(:has_audio) && options.has_key?(:has_video)
        has_audio = options[:has_audio]
        has_video = options[:has_video]
        raise ArgumentError, "has_audio and has_video can't both be false" if audio_and_video_options_both_false?(has_audio, has_video)
      end
      options['add_stream'] = stream_id

      @client.select_streams_for_archive(archive_id, options)
    end

    # Removes a stream from a currently running composed archive that was started with the
    # streamMode set to "manual". For a description of the feature, see
    # {https://tokbox.com/developer/rest/#selecting-archive-streams}.
    #
    # @param [String] archive_id
    #   The archive ID.
    #
    # @param [String] stream_id
    #   The ID for the stream to be removed from the archive
    #
    # @raise [ArgumentError]
    #   The archive_id parameter id is empty.
    #
    # @raise [ArgumentError]
    #   The stream_id parameter is empty.
    #
    def remove_stream(archive_id, stream_id)
      raise ArgumentError, "archive_id not provided" if archive_id.to_s.empty?
      raise ArgumentError, "stream_id not provided" if stream_id.to_s.empty?
      options = {}
      options['remove_stream'] = stream_id

      @client.select_streams_for_archive(archive_id, options)
    end

    private

    def audio_and_video_options_both_false?(has_audio, has_video)
      has_audio == false && has_video == false
    end

  end
end
