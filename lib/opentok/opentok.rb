require "opentok/constants"
require "opentok/session"
require "opentok/client"

require "base64"
require "resolv"
require "digest/hmac"
require "addressable/uri"
require "active_support/time"
# require 'rexml/document'


module OpenTok
  class OpenTok

    # don't want these to be mutable, may cause bugs related to inconsistency since these values are
    # cached in objects that this can create
    attr_reader :api_key, :api_url

    ##
    # Create a new OpenTok REST API client
    #
    # @param [String] API Key, developer identifier
    # @param [String] API Secret, developer identifier
    # @param [String] OpenTok endpoint, production by default
    def initialize(api_key, api_secret , api_url = ::OpenTok::API_URL)
      @api_key = api_key.to_s()
      @api_secret = api_secret
      # TODO: do we really need a copy of this in the instance or should we overwrite the module
      # constant so that other objects can access the same copy?
      @api_url = api_url
    end

    ##
    # Generate token for the given session_id
    #
    # @param [Hash] opts the options to create a token with.
    # @option opts [Time] :expire_time (optional) The time when the token will expire. If you do 
    # not specify this value, tokens expire in 24 hours after being created.
    # @option opts [String] :role (optional) Added in OpenTok v0.91.5. This defines the role the 
    # user will have. There are three roles: subscriber, publisher, and moderator.
    # @option opts [String] :data (optional) Added in OpenTok v0.91.20. A string containing metadata
    # describing the connection.
    def generate_token(session_id, opts = {})

      # normalize required data params
      role = opts.fetch(:role, :publisher)
      unless ROLES.has_key? role
        raise "'#{role}' is not a recognized role"
      end
      unless Session.belongs_to_api_key? session_id, @api_key
        raise "Cannot generate token for a session_id that doesn't belong to api_key: #{@api_key}"
      end

      # minimum data params
      data_params = {
        :role => role,
        :session_id => session_id,
        :create_time => Time.now.to_i,
        :nonce => Random.rand
      }

      # normalize and add additional data params
      unless (expire_time = opts[:expire_time]).nil?
        unless expire_time.between?(Time.now, Time.now + 30.days)
          raise "Expire time must be within the next 30 days" 
        end
        data_params[:expire_time] = expire_time.to_i
      end

      unless opts[:data].nil?
        unless (data = opts[:data].to_s).length < 1000
          raise "Connection data must be less than 1000 characters"
        end
        data_params[:connection_data] = data
      end

      data_string = Addressable::URI.form_encode data_params
      meta_string = Addressable::URI.form_encode({
        :partner_id => @api_key,
        :sig => sign_string(data_string, @api_secret)
      })

      TOKEN_SENTINEL + Base64.strict_encode64(meta_string + ":" + data_string)
    end

    ##
    # Creates a new OpenTok::Session and set it's session_id,
    # situating it in TokBox's global network near the IP of the specified @location@.
    #
    # param: location
    # param: p2p
    #
    def create_session(opts={})

      params = { p2p: opts.fetch(:p2p, false) }
      unless opts[:location].nil?
        raise "location must be an IPv4 address" unless opts[:location] =~ Resolv::IPv4::Regex
        params[:location] = opts[:location]
      end

      response = client.create_session(params)

      Session.new @api_key, @api_secret, response['sessions']['Session']['session_id']

      # doc = do_request '/session/create', opts

      # unless doc.get_elements('Errors').empty?
      #   raise OpenTokException.new nil, doc.get_elements('Errors')[0].get_elements('error')[0].children.to_s
      # end
      # Session.new doc.root.get_elements('Session')[0].get_elements('session_id')[0].children[0].to_s
    end

    # def archives
    #   @archives ||= Archives.new @partner_id, @partner_secret, @api_url
    # end

    protected

    def sign_string(data, secret)
      # TODO: if we want to support jRuby, this needs to be abstracted
      Digest::HMAC.hexdigest(data, secret, Digest::SHA1)
    end

    def client
      @client ||= Client.new @api_key, @api_secret, @api_url
    end

    # def do_request(path, params, token=nil)
    #   request = Request.new @api_url, token, @partner_id, @partner_secret
    #   body = request.fetch path, params
    #   REXML::Document.new body
    # end
  end
end
