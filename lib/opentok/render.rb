require "active_support/inflector"

module OpenTok
  # Represents an  Experience Composer render of an OpenTok session.
  # See {https://tokbox.com/developer/guides/experience-composer/ Experience Composer}.
  #
  # @attr [string] id
  #   The unique ID for the Experience Composer.
  #
  # @attr [string] session_id
  #   The session ID of the OpenTok session associated with this render.
  #
  # @attr [string] project_id
  #   The API key associated with the render.
  #
  # @attr [int] created_at
  #   The time the Experience Composer started, expressed in milliseconds since the Unix epoch.
  #
  # @attr [int] updated_at
  #   This is the UNIX timestamp when the Experience Composer status was last updated.
  #
  # @attr [string] url
  #   A publicly reachable URL controlled by the customer and capable of generating the content to be rendered without user intervention.
  #
  # @attr [string] resolution
  #   The resolution of the Experience Composer (either "640x480", "480x640", "1280x720", "720x1280", "1920x1080", or "1080x1920").
  #
  # @attr [string] status
  #   The status of the Experience Composer. Poll frequently to check status updates. This property set to one of the following:
  #     - "starting" — The Vonage Video API platform is in the process of connecting to the remote application at the URL provided. This is the initial state.
  #     - "started" — The Vonage Video API platform has successfully connected to the remote application server, and is publishing the web view to an OpenTok stream.
  #     - "stopped" — The Experience Composer has stopped.
  #     - "failed" — An error occurred and the Experience Composer could not proceed. It may occur at startup if the OpenTok server cannot connect to the remote 
  #                   application server or republish the stream. It may also occur at any point during the process due to an error in the Vonage Video API platform.
  #
  # @attr [string] reason
  #   The reason field is only available when the status is either "stopped" or "failed". If the status is stopped, the reason field will contain either
  #      "Max Duration Exceeded" or "Stop Requested." If the status is failed, the reason will contain a more specific error message.
  #
  # @attr [string] streamId
  #   The ID of the composed stream being published. The streamId is not available when the status is "starting" and may not be available when the status is "failed".
  class Render

    # @private
    def initialize(interface, json)
      @interface = interface
      # TODO: validate json fits schema
      @json = json
    end

    # A JSON-encoded string representation of the Experience Composer render.
    def to_json
      @json.to_json
    end

    # Stops the OpenTok Experience Composer render.
    def stop
      # TODO: validate returned json fits schema
      @json = @interface.stop @json['id']
    end

    # Gets info about the OpenTok Experience Composer render.
    def info
    # TODO: validate returned json fits schema
      @json = @interface.find @json['id']
    end
    
    # @private ignore
    def method_missing(method, *args, &block)
      camelized_method = method.to_s.camelize(:lower)
      if @json.has_key? camelized_method and args.empty?
        @json[camelized_method]
      else
        super method, *args, &block
      end
    end
  end
end
