=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010, TokBox, Inc.

=end

require 'cgi'
require 'openssl'
require 'base64'
require 'uri'
require 'net/https'
require 'rexml/document'

DIGEST  = OpenSSL::Digest::Digest.new('sha1')

module OpenTok

  class SessionPropertyConstants
    ECHOSUPPRESSION_ENABLED = "echoSuppression.enabled"; #Boolean
	  MULTIPLEXER_NUMOUTPUTSTREAMS = "multiplexer.numOutputStreams"; #Integer
	  MULTIPLEXER_SWITCHTYPE = "multiplexer.switchType"; #Integer
	  MULTIPLEXER_SWITCHTIMEOUT = "multiplexer.switchTimeout"; #Integer
  end

  class RoleConstants
    SUBSCRIBER = "subscriber" #Can only subscribe
    PUBLISHER = "publisher"   #Can publish, subscribe, and signal
    MODERATOR = "moderator"   #Can do the above along with  forceDisconnect and forceUnpublish
  end

  class OpenTokSDK
    attr_accessor :api_url
    
    @@TOKEN_SENTINEL = "T1=="
    @@SDK_VERSION = "tbruby-%s" % [ VERSION ]

    # Create a new OpenTokSDK object.
    #
    # The first two attributes are required; +parnter_id+ and +partner_secret+ are the api-key and secret
    # that are provided to you.
    # 
    # You can also pass in optional options;
    # * +:api_url+ sets the location of the api (staging or production)
    def initialize(partner_id, partner_secret, options = nil)
      @partner_id = partner_id
      @partner_secret = partner_secret.strip
      
      if options.is_a?(::Hash)
        @api_url = options[:api_url] || API_URL
      end
      
      unless @api_url
        @api_url = API_URL
      end
    end

    # Generate token for the given session_id. The options you can provide are;
    # * +:session_id+ (required) generate a token for the provided session
    # * +:create_time+ 
    # * +:expire_time+ (optional) The time when the token will expire, defined as an integer value for a Unix timestamp (in seconds). If you do not specify this value, tokens expire in 24 hours after being created.
    # * +:role+ (optional) Added in OpenTok v0.91.5. This defines the role the user will have. There are three roles: subscriber, publisher, and moderator.
    #
    # See http://www.tokbox.com/opentok/tools/documentation/overview/token_creation.html for more information on all options.
    def generate_token(opts = {})
      {:session_id=>nil, :create_time=>nil, :expire_time=>nil, :role=>nil}.merge!(opts)

      create_time = opts[:create_time].nil? ? Time.now  :  opts[:create_time]
      session_id = opts[:session_id].nil? ? '' : opts[:session_id]
      role = opts[:role].nil? ? RoleConstants::PUBLISHER : opts[:role]

      data_params = {
        :role => role,
        :session_id => session_id,
        :create_time => create_time.to_i,
        :nonce => rand
      }

      if not opts[:expire_time].nil?
        data_params[:expire_time] = opts[:expire_time].to_i
      end

      data_string = data_params.urlencode

      sig = sign_string(data_string, @partner_secret)
      meta_string = {
        :partner_id => @partner_id,
        :sdk_version => @@SDK_VERSION,
        :sig => sig
      }.urlencode

      @@TOKEN_SENTINEL + Base64.encode64(meta_string + ":" + data_string).gsub("\n","")
    end

    # Generates a new OpenTok::Session and set it's session_id, situating it in TokBox's global network near the IP of the specified @location@.
    #
    # See http://www.tokbox.com/opentok/tools/documentation/overview/session_creation.html for more information
    def create_session(location='', opts={})
      opts.merge!({:partner_id => @partner_id, :location=>location})
      doc = do_request("/session/create", opts)
      if not doc.get_elements('Errors').empty?
        raise OpenTokException.new doc.get_elements('Errors')[0].get_elements('error')[0].children.to_s
      end
      OpenTok::Session.new(doc.root.get_elements('Session')[0].get_elements('session_id')[0].children[0].to_s)
    end

    protected
    def sign_string(data, secret)
      OpenSSL::HMAC.hexdigest(DIGEST, secret, data)
    end

    def do_request(api_url, params, token=nil)
      url = URI.parse(@api_url + api_url)
      if not params.empty?
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data(params)
      else
        req = Net::HTTP::Get.new(url.path)
      end

      if not token.nil?
        req.add_field 'X-TB-TOKEN-AUTH', token
      else
        req.add_field 'X-TB-PARTNER-AUTH', "#{@partner_id}:#{@partner_secret}"
      end
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if @api_url.start_with?("https")
      res = http.start {|http| http.request(req)}
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        # OK
        doc = REXML::Document.new(res.read_body)
        return doc
      else
        res.error!
      end
    rescue Net::HTTPExceptions
      raise
      raise OpenTokException.new 'Unable to create fufill request: ' + $!
    rescue NoMethodError
      raise
      raise OpenTokException.new 'Unable to create a fufill request at this time: ' + $1
    end
  end
end

