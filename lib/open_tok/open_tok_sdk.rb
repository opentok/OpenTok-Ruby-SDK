=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.

=end

require 'openssl'
require 'base64'
require 'rexml/document'

DIGEST  = OpenSSL::Digest::Digest.new 'sha1'

module OpenTok

  autoload :OpenTokException        , 'open_tok/exception'
  autoload :Request                 , 'open_tok/request'
  autoload :RoleConstants           , 'open_tok/role_constants'
  autoload :Session                 , 'open_tok/session'
  autoload :SessionPropertyConstants, 'open_tok/session_property_constants'
  autoload :Utils                   , 'open_tok/utils'

  class OpenTokSDK
    attr_reader :api_url

    TOKEN_SENTINEL = "T1=="

    ##
    # Create a new OpenTok REST API client
    #
    # @param [String] API Key, developer identifier
    # @param [String] API Secret, developer identifier
    # @param [String] back_support @deprecated
    # @param [String] OpenTok endpoint, production by default
    def initialize(partner_id, partner_secret, back_support = '', api_url = OpenTok::API_URL)
      @partner_id = partner_id.to_s()
      @partner_secret = partner_secret
      @api_url = api_url
    end

    ##
    # Generate token for the given session_id
    #
    # @param [Hash] opts the options to create a token with.
    # @option opts [String] :session_id (mandatory) generate a token for the provided session
    # @option opts [String] :create_time (optional)
    # @option opts [String] :expire_time (optional) The time when the token will expire, defined as an integer value for a Unix timestamp (in seconds). If you do not specify this value, tokens expire in 24 hours after being created.
    # @option opts [String] :role (optional) Added in OpenTok v0.91.5. This defines the role the user will have. There are three roles: subscriber, publisher, and moderator.
    # @option opts [String] :connection_data (optional) Added in OpenTok v0.91.20. A string containing metadata describing the connection.
    # See http://www.tokbox.com/opentok/tools/documentation/overview/token_creation.html for more information on all options.
    def generate_token(opts = {})
      create_time = opts.fetch(:create_time, Time.now)
      session_id = opts.fetch(:session_id, '').to_s

      # check validity of session_id
      if !session_id || session_id.to_s.length == ""
        raise "Null or empty session ID is not valid"
      end

      begin
        subSessionId = session_id[2..session_id.length]
        subSessionId = subSessionId.sub("-","+").sub("_","/")
        decodedSessionId = Base64.decode64(subSessionId).split("~")
        (0..4).each do |n|
          if decodedSessionId and decodedSessionId.length > 1
            break
          end
          subSessionId = subSessionId+"="
        end
        unless decodedSessionId[1] == @partner_id
          raise "An invalid session ID was passed"
        end
      rescue Exception => e
        raise "An invalid session ID was passed"
      end


      role = opts.fetch(:role, RoleConstants::PUBLISHER)

      RoleConstants.is_valid?(role) or raise OpenTokException.new "'#{role}' is not a recognized role"

      data_params = {
        :role => role,
        :session_id => session_id.is_a?(Session) ? session_id.session_id : session_id,
        :create_time => create_time.to_i,
        :nonce => rand
      }

      unless opts[:expire_time].nil?
        opts[:expire_time].is_a?(Numeric) or raise OpenTokException.new 'Expire time must be a number'
        opts[:expire_time] < Time.now.to_i and raise OpenTokException.new 'Expire time must be in the future'
        opts[:expire_time] > (Time.now.to_i + 2592000) and raise OpenTokException.new 'Expire time must be in the next 30 days'
        data_params[:expire_time] = opts[:expire_time].to_i
      end

      unless opts[:connection_data].nil?
        opts[:connection_data].length > 1000 and raise OpenTokException.new 'Connection data must be less than 1000 characters'
        data_params[:connection_data] = opts[:connection_data]
      end

      data_string = Utils.urlencode_hash(data_params)

      sig = sign_string data_string, @partner_secret
      meta_string = Utils.urlencode_hash(:partner_id => @partner_id, :sig => sig)

      TOKEN_SENTINEL + Base64.encode64(meta_string + ":" + data_string).gsub("\n", '')
    end

    alias_method :generateToken, :generate_token

    ##
    # Generates a new OpenTok::Session and set it's session_id,
    # situating it in TokBox's global network near the IP of the specified @location@.
    #
    # param: location
    # param: opts: valid
    #
    # See http://www.tokbox.com/opentok/tools/documentation/overview/session_creation.html for more information
    def create_session(location='', opts={})
      opts.merge!({:location => location})
      doc = do_request '/session/create', opts

      unless doc.get_elements('Errors').empty?
        raise OpenTokException.new doc.get_elements('Errors')[0].get_elements('error')[0].children.to_s
      end
      Session.new doc.root.get_elements('Session')[0].get_elements('session_id')[0].children[0].to_s
    end

    alias_method :createSession, :create_session

    protected

    def sign_string(data, secret)
      OpenSSL::HMAC.hexdigest(DIGEST, secret, data)
    end

    def do_request(path, params, token=nil)
      request = Request.new @api_url, token, @partner_id, @partner_secret
      body = request.fetch path, params
      REXML::Document.new body
    end
  end
end
