require "resolv"
require "set"

require "opentok/constants"
require "opentok/session"
require "opentok/client"
require "opentok/token_generator"
require "opentok/connections"
require "opentok/archives"
require "opentok/sip"
require "opentok/streams"
require "opentok/signals"
require "opentok/broadcasts"
require "opentok/renders"
require "opentok/captions"

module OpenTok
  # Contains methods for creating OpenTok sessions and generating tokens. It also includes
  # methods for returning object that let you work with archives, work with live streaming
  # broadcasts, using SIP interconnect, sending signals to sessions, disconnecting clients from
  # sessions, and setting the layout classes for streams.
  #
  # To create a new OpenTok object, call the OpenTok constructor with your OpenTok API key
  # and the API secret for your {https://tokbox.com/account OpenTok project}. Do not
  # publicly share your API secret. You will use it with the OpenTok constructor (only on your web
  # server) to create OpenTok sessions.
  #
  # @attr_reader [String] api_secret @private The OpenTok API secret.
  # @attr_reader [String] api_key @private The OpenTok API key.
  #
  #
  # @!method generate_token(session_id, options)
  #   Generates a token for a given session.
  #
  #   @param [String] session_id The session ID of the session to be accessed by the client using
  #     the token.
  #
  #   @param [Hash] options A hash defining options for the token.
  #   @option options [Symbol] :role The role for the token. Set this to one of the following
  #     values:
  #     * <code>:subscriber</code> -- A subscriber can only subscribe to streams.
  #
  #     * <code>:publisher</code> -- A publisher can publish streams, subscribe to
  #       streams, and signal. (This is the default value if you do not specify a role.)
  #
  #     * <code>:moderator</code> -- In addition to the privileges granted to a
  #       publisher, a moderator can perform moderation functions, such as forcing clients
  #       to disconnect, to stop publishing streams, or to mute audio in published streams. See the
  #       {https://tokbox.com/developer/guides/moderation/ Moderation developer guide}.
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
  class OpenTok

    include TokenGenerator
    generates_tokens({
      :api_key => ->(instance) { instance.api_key },
      :api_secret => ->(instance) { instance.api_secret }
    })

    # @private
    # don't want these to be mutable, may cause bugs related to inconsistency since these values are
    # cached in objects that this can create
    attr_reader :api_key, :api_secret, :timeout_length, :api_url, :ua_addendum

    ##
    # Create a new OpenTok object.
    #
    # @param [String] api_key The OpenTok API key for your
    #   {https://tokbox.com/account OpenTok project}.
    # @param [String] api_secret Your OpenTok API key.
    # @option opts [Symbol] :api_url Do not set this parameter. It is for internal use by Vonage.
    # @option opts [Symbol] :ua_addendum Do not set this parameter. It is for internal use by Vonage.
    # @option opts [Symbol] :timeout_length Custom timeout in seconds. If not provided, defaults to 2 seconds.
    def initialize(api_key, api_secret, opts={})
      @api_key = api_key.to_s()
      @api_secret = api_secret
      @timeout_length = opts[:timeout_length] || 2
      @api_url = opts[:api_url] || API_URL
      @ua_addendum = opts[:ua_addendum]
    end

    # Creates a new OpenTok session and returns the session ID, which uniquely identifies
    # the session.
    #
    # For example, when using the OpenTok JavaScript library, use the session ID when calling the
    # OT.initSession()</a> method (to initialize an OpenTok session).
    #
    # OpenTok sessions do not expire. However, authentication tokens do expire (see the
    # generateToken() method). Also note that sessions cannot explicitly be destroyed.
    #
    # A session ID string can be up to 255 characters long.
    #
    # Calling this method results in an OpenTokException in the event of an error.
    # Check the error message for details.
    #
    # You can also create a session using the OpenTok REST API (see
    # http://www.tokbox.com/opentok/api/#session_id_production) or at your
    # {https://tokbox.com/account OpenTok account page}.
    #
    # @param [Hash] opts (Optional) This hash defines options for the session.
    #
    # @option opts [Symbol] :media_mode Determines whether the session will transmit streams the
    #   using OpenTok Media Router (<code>:routed</code>) or not (<code>:relayed</code>).
    #   By default, this property is set to <code>:relayed</code>.
    #
    #   With the <code>media_mode</code> property set to <code>:relayed</code>, the session
    #   will attempt to transmit streams directly between clients. If clients cannot connect due to
    #   firewall restrictions, the session uses the OpenTok TURN server to relay audio-video
    #   streams.
    #
    #   With the <code>media_mode</code> property set to <code>:routed</code>, the session will use
    #   the {https://tokbox.com/opentok/tutorials/create-session/#media-mode OpenTok Media Router}.
    #   The OpenTok Media Router provides the following benefits:
    #
    #   * The OpenTok Media Router can decrease bandwidth usage in multiparty sessions.
    #     (When the <code>media_mode</code> property is set to <code>:relayed</code>,
    #     each client must send a separate audio-video stream to each client subscribing to
    #     it.)
    #   * The OpenTok Media Router can improve the quality of the user experience through
    #     {https://tokbox.com/platform/fallback audio fallback and video recovery}. With
    #     these features, if a client's connectivity degrades to a degree that
    #     it does not support video for a stream it's subscribing to, the video is dropped on
    #     that client (without affecting other clients), and the client receives audio only.
    #     If the client's connectivity improves, the video returns.
    #   * The OpenTok Media Router supports the
    #     {https://tokbox.com/opentok/tutorials/archiving archiving}
    #     feature, which lets you record, save, and retrieve OpenTok sessions.
    #
    # @option opts [String] :location  An IP address that the OpenTok servers will use to
    #     situate the session in its global network. If you do not set a location hint,
    #     the OpenTok servers will be based on the first client connecting to the session.
    #
    # @option opts [Symbol] :archive_mode Determines whether the session will be archived
    #     automatically (<code>:always</code>) or not (<code>:manual</code>). When using automatic
    #     archiving, the session must use the <code>:routed</code> media mode.
    #
    # @option opts [Symbol] :archive_name The name to use for archives in auto-archived sessions.
    #     When setting this option, the :archive_mode option must be set to :always or an error will result.
    #     The length of the archive name can be up to 80 chars.
    #     Due to encoding limitations the following special characters are translated to a colon (:) character: ~, -, _.
    #     If you do not set a name and the archiveMode option is set to always, the archive name will be empty.
    #
    # @option opts [Symbol] :archive_resolution The resolution of archives in an auto-archived session.
    #     Valid values are "480x640", "640x480" (the default), "720x1280", "1280x720", "1080x1920", and "1920x1080".
    #     When setting this option, the :archive_mode option must be set to :always or an error will result.
    #
    # @option opts [true, false] :e2ee
    #     (Boolean, optional) — Whether the session uses end-to-end encryption from client to client (default: false).
    #     This should not be set to `true` if `:media_mode` is `:relayed`.
    #     See the {https://tokbox.com/developer/guides/end-to-end-encryption/ documentation} for more information.
    #
    # @return [Session] The Session object. The session_id property of the object is the session ID.
    def create_session(opts={})

      # normalize opts so all keys are symbols and only include valid_opts
      valid_opts = [ :media_mode, :location, :archive_mode, :archive_name, :archive_resolution, :e2ee ]
      opts = opts.inject({}) do |m,(k,v)|
        if valid_opts.include? k.to_sym
          m[k.to_sym] = v
        end
        m
      end

      # keep opts around for Session constructor, build REST params
      params = opts.clone

      # validate input combinations
      raise ArgumentError, "A session with always archive mode must also have the routed media mode." if (params[:archive_mode] == :always && params[:media_mode] == :relayed)

      raise ArgumentError, "A session with relayed media mode should not have e2ee set to true." if (params[:media_mode] == :relayed && params[:e2ee] == true)

      raise ArgumentError, "A session with always archive mode must not have e2ee set to true." if (params[:archive_mode] == :always && params[:e2ee] == true)

      # anything other than :relayed sets the REST param to "disabled", in which case we force
      # opts to be :routed. if we were more strict we could raise an error when the value isn't
      # either :relayed or :routed
      if params.delete(:media_mode) == :routed
        params["p2p.preference"] = "disabled"
      else
        params["p2p.preference"] = "enabled"
        opts[:media_mode] = :relayed
      end
      # location is optional, but it has to be an IP address if specified at all
      unless params[:location].nil?
        raise "location must be an IPv4 address" unless params[:location] =~ Resolv::IPv4::Regex
      end
      # archive mode is optional, but it has to be one of the valid values if present
      unless params[:archive_mode].nil?
        raise "archive mode must be either always or manual" unless ARCHIVE_MODES.include? params[:archive_mode].to_sym
        raise ArgumentError, "archive name and/or archive resolution must not be set if archive mode is manual" if params[:archive_mode] == :manual && (params[:archive_name] || params[:archive_resolution])
      end

      response = client.create_session(params)
      Session.new api_key, api_secret, response['sessions']['Session']['session_id'], opts
    end

    # An Archives object, which lets you work with OpenTok archives.
    def archives
      @archives ||= Archives.new client
    end

    # A Broadcasts object, which lets you work with OpenTok live streaming broadcasts.
    def broadcasts
      @broadcasts ||= Broadcasts.new client
    end

    # A Captions object, which lets you start and stop live captions for an OpenTok session.
    def captions
      @captions ||= Captions.new client
    end

    # A Connections object, which lets you disconnect clients from an OpenTok session.
    def connections
      @connections ||= Connections.new client
    end

    # A Renders object, which lets you work with OpenTok Experience Composer renders.
    def renders
      @renders ||= Renders.new client
    end

    # A Sip object, which lets you use the OpenTok SIP gateway.
    def sip
      @sip ||= Sip.new client
    end

    # A Streams object, which lets you work with OpenTok live streaming broadcasts.
    def streams
      @streams ||= Streams.new client
    end

    # A Signals object, which lets you send signals to OpenTok sessions.
    def signals
      @signals ||= Signals.new client
    end

    # A WebSocket object, which lets you connect OpenTok streams to a WebSocket URI.
    def websocket
      @websocket ||= WebSocket.new client
    end

    protected
    def client
      @client ||= Client.new api_key, api_secret, api_url, ua_addendum, timeout_length: @timeout_length
    end

  end
end
