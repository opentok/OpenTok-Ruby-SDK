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
    # @attr [string] partner_id
    #   The API key associated with the archive.
    #
    # @attr [string] reason
    #   For archives with the status "stopped", this can be set to "90 mins exceeded", "failure",
    #   "session ended", or "user initiated". For archives with the status "failed", this can be set
    #   to "system failure".
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
    #   * "failed" -- The archive recording failed.
    #   * "started" -- The archive started and is in the process of being recorded.
    #   * "stopped" -- The archive stopped recording.
    #   * "uploaded" -- The archive is available for download from the the upload target
    #     S3 bucket.
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

    # A JSON encoded string representation of the archive
    def to_json
      @json.to_json
    end

    # Stops an OpenTok archive that is being recorded.
    #
    # Archives automatically stop recording after 90 minutes or when all clients have disconnected
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

    # @private ignore
    def method_missing(method, *args, &block)
      camelized_method = method.to_s.camelize(:lower)
      if @json.has_key? camelized_method and args.empty?
        # TODO: convert create_time method call to a Time object
        @json[camelized_method]
      else
        super method, *args, &block
      end
    end
  end
end
