require "active_support/inflector"

module OpenTok
    # Represents a connection in an OpenTok session.
    #
    # @attr [String] connection_id
    #   The ID of the connection.
    #
    # @attr [Integer] created_at
    #   The timestamp when the connection was created, expressed in milliseconds since the Unix epoch.
    #
    # @attr [String] connection_state
    #   The state of the connection.
    #
  class Connection
    # @private
    def initialize(interface, session_id, json)
      @interface = interface
      @session_id = session_id
      # TODO: validate json fits schema
      @json = json
    end

    # A JSON-encoded string representation of the connection.
    def to_json
      @json.to_json
    end

    # Forces the disconnection of this connection from the OpenTok session.
    #
    # A client must be actively connected to the OpenTok session for you to disconnect it.
    def force_disconnect
      # TODO: validate returned json fits schema
      @json = @interface.forceDisconnect(@session_id, @json['connectionId'])
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
