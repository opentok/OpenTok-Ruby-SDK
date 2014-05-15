require "multi_json"
require "active_support/inflector"

module OpenTok
    # Represents an archive of an OpenTok session.
    class Archive

    # @private
    def initialize(interface, json)
      @interface = interface
      # TODO: validate json fits schema
      @json = json
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

    # @private
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
