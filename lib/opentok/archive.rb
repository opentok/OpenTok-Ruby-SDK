require "active_support/inflector"

module OpenTok
    # Represents an archive of an OpenTok session.
    #
    # @attr [int] created_at
    #   The time at which the archive was created, in milliseconds since the UNIX epoch.
    #
    # @attr [string] duration
    #   The duration of the archive, in milliseconds.
    #
    # @attr [string] id
    #   The archive ID.
    #
    # @attr [string] name
    #   The name of the archive. If no name was provided when the archive was created, this is set
    #   to null.
    #
    # @attr [true, false] has_audio
    #   Whether the archive has an audio track (true) or not (false).
    #
    # @attr [true, false] has_video
    #   Whether the archive has a video track (true) or not (false).
    #
    # @attr [String] output_mode
    #   Whether all streams in the archive are recorded to a single file (<code>:composed</code>)
    #   or to individual files (<code>:individual</code>).
    #
    # @attr [string] partner_id
    #   The API key associated with the archive.
    #
    # @attr [string] reason
    #   For archives with the status "stopped" or "failed", this string describes the
    #   reason the archive stopped (such as "maximum duration exceeded") or failed.
    #
    # @attr [string] session_id
    #   The session ID of the OpenTok session associated with this archive.
    #
    # @attr [float] size
    #   The size of the MP4 file. For archives that have not been generated, this value is set to 0.
    #
    # @attr [string] status
    #   The status of the archive, which can be one of the following:
    #
    #   * "available" -- The archive is available for download from the OpenTok cloud.
    #   * "expired" -- The archive is no longer available for download from the OpenTok cloud.
    #   * "failed" -- The archive recording failed.
    #   * "paused" -- The archive is in progress and no clients are publishing streams to the
    #     session. When an archive is in progress and any client publishes a stream, the status is
    #     "started". When an archive is paused, nothing is recorded. When a client starts publishing
    #     a stream, the recording starts (or resumes). If all clients disconnect from a session that
    #     is being archived, the status changes to "paused", and after 60 seconds the archive
    #     recording stops (and the status changes to "stopped").
    #   * "started" -- The archive started and is in the process of being recorded.
    #   * "stopped" -- The archive stopped recording.
    #   * "uploaded" -- The archive is available for download from the the upload target
    #     Amazon S3 bucket or Windows Azure container you set for your
    #     {https://tokbox.com/account OpenTok project}.
    #
    # @attr [string] url
    #   The download URL of the available MP4 file. This is only set for an archive with the status set to
    #   "available"; for other archives, (including archives with the status "uploaded") this property is
    #   set to null. The download URL is obfuscated, and the file is only available from the URL for
    #   10 minutes. To generate a new URL, call the Archive.listArchives() or OpenTok.getArchive() method.
  class Archive

    # @private
    def initialize(interface, json)
      @interface = interface
      # TODO: validate json fits schema
      @json = json
    end

    # A JSON-encoded string representation of the archive.
    def to_json
      @json.to_json
    end

    # Stops an OpenTok archive that is being recorded.
    #
    # Archives automatically stop recording after 120 minutes or when all clients have disconnected
    # from the session being archived.
    def stop
      # TODO: validate returned json fits schema
      @json = @interface.stop_by_id @json['id']
    end

    # Deletes an OpenTok archive.
    #
    # You can only delete an archive which has a status of "available" or "uploaded". Deleting an
    # archive removes its record from the list of archives. For an "available" archive, it also
    # removes the archive file, making it unavailable for download.
    def delete
      # TODO: validate returned json fits schema
      @json = @interface.delete_by_id @json['id']
    end

    # Sets the layout type for a composed archive. For a description of layout types, see
    # {https://tokbox.com/developer/guides/archiving/layout-control.html Customizing
    # the video layout for composed archives}.
    #
    # @option options [String] :type 
    #   The layout type. Set this to "bestFit", "pip", "verticalPresentation",
    #   "horizontalPresentation", "focus", or "custom".
    #
    # @option options [String] :stylesheet
    #   The stylesheet for a custom layout. Set this parameter
    #   if you set <code>type</code> to <code>"custom"</code>. Otherwise, leave it undefined.
    #
    # @raise [ArgumentError] The archive_id or options parameter is empty. Or the "custom"
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
    def layout(opts= {})
      # TODO: validate returned json fits schema
      @json = @interface.layout(@json['id'], opts)
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
