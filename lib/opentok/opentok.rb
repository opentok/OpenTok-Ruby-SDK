require "opentok/constants"
require "opentok/session"
require "opentok/client"
require "opentok/token_generator"
require "opentok/archives"
require "opentok/sip"

require "resolv"
require "set"

module OpenTok
  # Contains methods for creating OpenTok sessions, generating tokens, and working with archives.
  #
  # To create a new OpenTok object, call the OpenTok constructor with your OpenTok API key
  # and the API secret from the OpenTok dashboard (https://dashboard.tokbox.com). Do not
  # publicly share your API secret. You will use it with the OpenTok constructor (only on your web
  # server) to create OpenTok sessions.
  #
  # @attr_reader [String] api_secret @private The OpenTok API secret.
  # @attr_reader [String] api_key @private The OpenTok API key.
  #
  #
  # @!method generate_token(options)
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
    attr_reader :api_key, :api_secret, :api_url, :ua_addendum

    ##
    # Create a new OpenTok object.
    #
    # @param [String] api_key Your OpenTok API key. See the OpenTok dashboard
    #   (https://dashboard.tokbox.com).
    # @param [String] api_secret Your OpenTok API key.
    # @option opts [Symbol] :api_url Do not set this parameter. It is for internal use by TokBox.
    # @option opts [Symbol] :ua_addendum Do not set this parameter. It is for internal use by TokBox.
    def initialize(api_key, api_secret, opts={})
      @api_key = api_key.to_s()
      @api_secret = api_secret
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
    # http://www.tokbox.com/opentok/api/#session_id_production) or the OpenTok dashboard
    # (see https://dashboard.tokbox.com/projects).
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
    # @return [Session] The Session object. The session_id property of the object is the session ID.
    def create_session(opts={})

      # normalize opts so all keys are symbols and only include valid_opts
      valid_opts = [ :media_mode, :location, :archive_mode ]
      opts = opts.inject({}) do |m,(k,v)|
        if valid_opts.include? k.to_sym
          m[k.to_sym] = v
        end
        m
      end

      # keep opts around for Session constructor, build REST params
      params = opts.clone

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
      end

      raise "A session with always archive mode must also have the routed media mode." if (params[:archive_mode] == :always && params[:media_mode] == :relayed)

      response = client.create_session(params)
      Session.new api_key, api_secret, response['sessions']['Session']['session_id'], opts
    end

    # An Archives object, which lets you work with OpenTok archives.
    def archives
      @archives ||= Archives.new client
    end

    def sip
      @sip ||= Sip.new client
    end

    protected

    def client
      @client ||= Client.new api_key, api_secret, api_url, ua_addendum
    end

  end
end
