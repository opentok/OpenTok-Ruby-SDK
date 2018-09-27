require "opentok/client"


module OpenTok
  # A class for working with OpenTok archives.
  class Broadcasts

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
    # @param [Hash] options  A hash with the key 'name', 'has_audio', and 'has_video' (or
    # :name.
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
    #   this property and set the outputMode property to "individual", the call to the REST method
    #   results in an error.
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
      raise ArgumentError, "options cannot be empty" if options.empty?
      broadcast_json = @client.start_broadcast(session_id, options)
      Broadcast.new self, broadcast_json
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
    def find(broadcast_id)
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      broadcast_json = @client.get_broadcast(broadcast_id.to_s)
      Broadcast.new self, broadcast_json
    end


    # Stops an OpenTok archive that is being recorded.
    #
    # Archives automatically stop recording after 90 minutes or when all clients have disconnected
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
    def stop(broadcast_id)
      raise ArgumentError, "broadcast_id not provided" if broadcast_id.to_s.empty?
      broadcast_json = @client.stop_archive(broadcast_id)
      Broadcast.new self, broadcast_json
    end

    def layout(broadcast_id)

    end


  end
end
