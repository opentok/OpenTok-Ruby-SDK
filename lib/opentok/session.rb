require "base64"
require "opentok/token_generator"

module OpenTok

  # Represents an OpenTok session.
  #
  # Use the OpenTok.createSession() method to create an OpenTok session. Use the
  # session_id property of the Session object to get the session ID.
  #
  # @attr_reader [String] session_id The session ID.
  # @attr_reader [String] api_secret @private The OpenTok API secret.
  # @attr_reader [String] api_key @private The OpenTok API key.
  # @attr_reader [String] media_mode Set to :routed if the session uses the OpenTok Media Router
  #   or to :relayed if the session attempts to transmit streams directly between clients.
  #
  # @attr_reader [String] location The location hint IP address. See the OpenTok.createSession()
  #   method.
  #
  # @attr_reader [String] archive_mode Whether the session will be archived automatically
  #  (<code>:always</code>) or not (<code>:manual</code>).
  #
  # @!method generate_token(options)
  #   Generates a token.
  #
  #   @param [Hash] options
  #   @option options [Symbol] :role The role for the token. Set this to one of the following
  #     values:
  #     * <code>:subscriber</code> -- A subscriber can only subscribe to streams.
  #
  #     * <code>:publisher</code> -- A publisher can publish streams, subscribe to
  #       streams, and signal. (This is the default value if you do not specify a role.)
  #
  #     * <code>:moderator</code> -- In addition to the privileges granted to a
  #       publisher, in clients using the OpenTok.js library, a moderator can call the
  #       <code>forceUnpublish()</code> and <code>forceDisconnect()</code> method of the
  #       Session object.
  #   @option options [integer] :expire_time The expiration time, in seconds since the UNIX epoch.
  #     Pass in 0 to use the default expiration time of 24 hours after the token creation time.
  #     The maximum expiration time is 30 days after the creation time.
  #   @option options [String] :data A string containing connection metadata describing the
  #     end-user. For example, you can pass the user ID, name, or other data describing the
  #     end-user. The length of the string is limited to 1000 characters. This data cannot be
  #     updated once it is set.
  #   @option options [Array] :initial_layout_class_list
  #     An array of class names (strings) to be used as the initial layout classes for streams
  #     published by the client. Layout classes are used in customizing the layout of videos in
  #     {https://tokbox.com/developer/guides/broadcast/live-streaming/ live streaming broadcasts}
  #     and {https://tokbox.com/developer/guides/archiving/layout-control.html composed archives}.
  #   @return [String] The token string.
  class Session

    include TokenGenerator
    generates_tokens({
      :api_key => ->(instance) { instance.api_key },
      :api_secret => ->(instance) { instance.api_secret },
      :session_id => ->(instance) { instance.session_id }
    })

    attr_reader :session_id, :media_mode, :location, :archive_mode, :api_key, :api_secret

    # @private
    # this implementation doesn't completely understand the format of a Session ID
    # that is intentional, that is too much responsibility.
    def self.belongs_to_api_key?(session_id, api_key)
      encoded = session_id[2..session_id.length]
                          .gsub('-', '+')
                          .gsub('_', '/')
      decoded = Base64.decode64(encoded)
      decoded.include? api_key
    end

    # @private
    def initialize(api_key, api_secret, session_id, opts={})
      @api_key, @api_secret, @session_id = api_key, api_secret, session_id
      @media_mode, @location, @archive_mode = opts.fetch(:media_mode, :relayed), opts[:location], opts.fetch(:archive_mode, :manual)
    end

    # @private
    def to_s
      @session_id
    end
  end
end
