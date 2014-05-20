require "opentok/constants"
require "opentok/session"
require "opentok/client"
require "opentok/token_generator"
require "opentok/archives"

require "resolv"

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
  #   @param [String] sessioin_id The session ID of the session to be accessed by the client using
  #     the token.
  #
  #   @param [Hash] options A hash defining options for the token.
  #   @option options [String] :role The role for the token. Valid values are defined in the Role
  #     class:
  #     * <code>SUBSCRIBER</code> -- A subscriber can only subscribe to streams.
  #
  #     * <code>PUBLISHER</code> -- A publisher can publish streams, subscribe to
  #       streams, and signal. (This is the default value if you do not specify a role.)
  #
  #     * <code>MODERATOR</code> -- In addition to the privileges granted to a
  #       publisher, in clients using the OpenTok.js 2.2 library, a moderator can call the
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
    attr_reader :api_key, :api_secret, :api_url

    ##
    # Create a new OpenTok object.
    #
    # @param [String] api_key Your OpenTok API key. See the OpenTok dashboard
    #   (https://dashboard.tokbox.com).
    # @param [String] api_secret Your OpenTok API key.
    # @param [String] api_url Do not set this parameter. It is for internal use by TokBox.
    def initialize(api_key, api_secret , api_url = ::OpenTok::API_URL)
      @api_key = api_key.to_s()
      @api_secret = api_secret
      # TODO: do we really need a copy of this in the instance or should we overwrite the module
      # constant so that other objects can access the same copy?
      @api_url = api_url
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
    # @option opts [Boolean] :p2p The session's streams will be transmitted directly between
    #     peers (true) or using the OpenTok Media Router (false). By default, sessions use
    #     the OpenTok Media Router.
    #
    #     The OpenTok Media Router</a> provides benefits not available in peer-to-peer sessions.
    #     For example, the OpenTok Media Router can decrease bandwidth usage in multiparty sessions.
    #     Also, the OpenTok Media Router can improve the quality of the user experience through
    #     dynamic traffic shaping. For more information, see
    #     http://www.tokbox.com/blog/mantis-next-generation-cloud-technology-for-webrtc and
    #     http://www.tokbox.com/blog/quality-of-experience-and-traffic-shaping-the-next-step-with-mantis.
    #
    #     For peer-to-peer sessions, the session will attempt to transmit streams directly
    #     between clients. If clients cannot connect due to firewall restrictions, the session uses
    #     the OpenTok TURN server to relay audio-video streams.
    #
    #     You will be billed for streamed minutes if you use the OpenTok Media Router or if the
    #     peer-to-peer session uses the OpenTok TURN server to relay streams. For information on
    #     pricing, see the OpenTok pricing page (http://www.tokbox.com/pricing).
    #
    # @option opts [String] :location  An IP address that the OpenTok servers will use to
    #     situate the session in its global network. If you do not set a location hint,
    #     the OpenTok servers will be based on the first client connecting to the session.
    #
    # @return [Session] The Session object. The session_id property of the object is the session ID.
    def create_session(opts={})

      # normalize opts so all keys are symbols and only include valid_opts
      valid_opts = [ :media_mode, :location ]
      opts = opts.inject({}) do |m,(k,v)|
        if valid_opts.include? k.to_sym
          m[k.to_sym] = v
        end
        m
      end

      # keep opts around for Session constructor, build REST params
      params = opts.clone

      # anything other than :relayed sets the REST param to "enabled", in which case we force
      # opts to be :routed. if we were more strict we could raise an error when the value isn't
      # either :relayed or :routed
      if params.delete(:media_mode) == :relayed
        params["p2p.preference"] = "enabled"
      else
        params["p2p.preference"] = "disabled"
        opts[:media_mode] = :routed
      end
      # location is optional, but it has to be an IP address if specified at all
      unless params[:location].nil?
        raise "location must be an IPv4 address" unless params[:location] =~ Resolv::IPv4::Regex
      end

      response = client.create_session(params)
      Session.new api_key, api_secret, response['sessions']['Session']['session_id'], opts
    end

    # An Archives object, which lets you work with OpenTok 2.0 archives.
    def archives
      @archives ||= Archives.new client
    end

    protected

    def client
      @client ||= Client.new api_key, api_secret, api_url
    end

  end
end
