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
    # @option options [String] :output_mode Whether all streams in the archive are recorded
    #     to a single file (<code>:composed</code>, the default) or to individual files
    #     (<code>:individual</code>). For more information on archiving and the archive file
    #     formats, see the {https://tokbox.com/opentok/tutorials/archiving OpenTok archiving}
    #     programming guide.
    # @option options [String] :resolution The resolution of the archive, either "640x480" (SD, the
    #   default) or "1280x720" (HD). This property only applies to composed archives. If you set
    #   this property and set the outputMode property to "individual", the call the method
    #   results in an error.
    # @option options [Hash] :layout Specify this to assign the initial layout type for
    #   the archive. This applies only to composed archives. This is a hash containing two keys:
    #   <code>:type</code> and <code>:stylesheet<code>. Valid values for <code>:type</code> are
    #   "bestFit" (best fit), "custom" (custom), "horizontalPresentation" (horizontal presentation),
    #   "pip" (picture-in-picture), and "verticalPresentation" (vertical presentation)).
    #   If you specify a "custom" layout type, set the <code>:stylesheet</code> key to the
    #   stylesheet (CSS). (For other layout types, do not set the <code>:stylesheet</code> key.)
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
      valid_opts = [ :name, :has_audio, :has_video, :output_mode, :resolution, :layout ]
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
      valid_non_custom_type = ["bestFit","horizontalPresentation","pip", "verticalPresentation", ""].include? type
      raise ArgumentError, "type is not valid or stylesheet not needed" if !valid_non_custom_type
      raise ArgumentError, "type is not valid or stylesheet not needed" if valid_non_custom_type and options.key? :stylesheet
      response = @client.layout_archive(archive_id, options)
      (200..300).include? response.code
    end
  end
end
