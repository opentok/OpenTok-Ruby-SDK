=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.

=end

require 'openssl'
require 'base64'
require 'rexml/document'

DIGEST  = OpenSSL::Digest::Digest.new('sha1')

module OpenTok

  # SessionPropertyConstants
  #
  # * +ECHOSUPPRESSION_ENABLED+ boolean
  # * +MULTIPLEXER_NUMOUTPUTSTREAMS+ integer
  # * +MULTIPLEXER_SWITCHTYPE+ integer
  # * +MULTIPLEXER_SWITCHTIMEOUT+ integer
  # * +P2P_PREFERENCE+ string
  module SessionPropertyConstants
    ECHOSUPPRESSION_ENABLED = "echoSuppression.enabled" #Boolean
    MULTIPLEXER_NUMOUTPUTSTREAMS = "multiplexer.numOutputStreams" #Integer
    MULTIPLEXER_SWITCHTYPE = "multiplexer.switchType" #Integer
    MULTIPLEXER_SWITCHTIMEOUT = "multiplexer.switchTimeout" #Integer
    P2P_PREFERENCE = "p2p.preference" #String
  end

  # RoleConstants
  #
  # * +SUBSCRIBER+ Can only subscribe
  # * +PUBLISHER+ Can publish, subscribe, and signal
  # * +MODERATOR+ Can do the above along with forceDisconnect and forceUnpublish
  module RoleConstants
    SUBSCRIBER = "subscriber" #Can only subscribe
    PUBLISHER = "publisher" #Can publish, subscribe, and signal
    MODERATOR = "moderator" #Can do the above along with  forceDisconnect and forceUnpublish
  end

  class OpenTokSDK
    attr_accessor :api_url

    @@TOKEN_SENTINEL = "T1=="

    # Create a new OpenTokSDK object.
    #
    # The first two attributes are required; +parnter_id+ and +partner_secret+ are the api-key and secret
    # that are provided to you.
    def initialize(partner_id, partner_secret, backSupport="")
      @partner_id = partner_id
      @partner_secret = partner_secret
      @api_url = API_URL
    end

    # Generate token for the given session_id. The options you can provide are;
    # * +:session_id+ (required) generate a token for the provided session
    # * +:create_time+
    # * +:expire_time+ (optional) The time when the token will expire, defined as an integer value for a Unix timestamp (in seconds). If you do not specify this value, tokens expire in 24 hours after being created.
    # * +:role+ (optional) Added in OpenTok v0.91.5. This defines the role the user will have. There are three roles: subscriber, publisher, and moderator.
    # * +:connection_data+ (optional) Added in OpenTok v0.91.20. A string containing metadata describing the connection.
    #
    # See http://www.tokbox.com/opentok/tools/documentation/overview/token_creation.html for more information on all options.
    def generate_token(opts = {})
      { :session_id => nil, :create_time => nil, :expire_time => nil, :role => nil, :connection_data => nil }.merge!(opts)

      create_time = opts[:create_time].nil? ? Time.now : opts[:create_time]
      session_id = opts[:session_id].nil? ? '' : opts[:session_id]
      role = opts[:role].nil? ? RoleConstants::PUBLISHER : opts[:role]

      if role != RoleConstants::SUBSCRIBER && role != RoleConstants::PUBLISHER && role != RoleConstants::MODERATOR
        raise OpenTokException.new "'#{role}' is not a recognized role"
      end

      data_params = {
        :role => role,
        :session_id => session_id,
        :create_time => create_time.to_i,
        :nonce => rand
      }

      if not opts[:expire_time].nil?
        raise OpenTokException.new 'Expire time must be a number' if not opts[:expire_time].is_a?(Numeric)
        raise OpenTokException.new 'Expire time must be in the future' if opts[:expire_time] < Time.now.to_i
        raise OpenTokException.new 'Expire time must be in the next 30 days' if opts[:expire_time] > (Time.now.to_i + 2592000)
        data_params[:expire_time] = opts[:expire_time].to_i
      end

      if not opts[:connection_data].nil?
        raise OpenTokException.new 'Connection data must be less than 1000 characters' if opts[:connection_data].length > 1000
        data_params[:connection_data] = opts[:connection_data]
      end

      data_string = OpenTok::Utils.urlencode_hash(data_params)

      sig = sign_string(data_string, @partner_secret)
      meta_string = OpenTok::Utils.urlencode_hash(:partner_id => @partner_id, :sig => sig)

      @@TOKEN_SENTINEL + Base64.encode64(meta_string + ":" + data_string).gsub("\n", '')
    end
    alias_method :generateToken, :generate_token

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
    alias_method :createSession, :create_session

    # This method takes two parameters. The first parameter is the +archive_id+ of the archive that contains the video (a String). The second parameter is the +token+ (a String)
    # The method returns an +OpenTok::Archive+ object. The resources property of this object is an array of OpenTok::ArchiveVideoResource objects. Each OpenTok::ArchiveVideoResource object represents a video in the archive.
    def get_archive_manifest(archive_id, token)
      # TODO: verify that token is MODERATOR token

      doc = do_request("/archive/getmanifest/#{archive_id}", {}, token)
      if not doc.get_elements('Errors').empty?
        raise OpenTokException.new doc.get_elements('Errors')[0].get_elements('error')[0].children.to_s
      end
      OpenTok::Archive.parse_manifest(doc.get_elements('manifest')[0], @api_url, token)
    end
    alias_method :getArchiveManifest, :get_archive_manifest

    def delete_archive( aid, token )
      deleteURL = "/hl/archive/delete/#{aid}"
      doc = do_request( deleteURL, {test:'none'}, token )
      errors = doc.get_elements('Errors')
      if doc.get_elements('Errors').empty?
        #error = errors[0].get_elements('error')[0]
        #errorCode = attributes['code']
        return true
      else
        return false
      end
    end
    alias_method :deleteArchive, :delete_archive

    def stitchArchive(aid)
      stitchURL = "/hl/archive/#{aid}/stitch"
      request = OpenTok::Request.new(@api_url, nil, @partner_id, @partner_secret)
      response = request.sendRequest(stitchURL, {test:'none'})
      case response.code
      when '201'
        return {:code=>201, :message=>"Successfully Created", :location=>response["location"]}
      when '202'
        return {:code=>202, :message=>"Processing"}
      when '403'
        return {:code=>403, :message=>"Invalid Credentials"}
      when '404'
        return {:code=>404, :message=>"Archive Does Not Exist"}
      else
        return {:code=>500, :message=>"Server Error"}
      end
      return {}
    end
    alias_method :stitch, :stitchArchive

    protected
    def sign_string(data, secret)
      OpenSSL::HMAC.hexdigest(DIGEST, secret, data)
    end

    def do_request(path, params, token=nil)
      request = OpenTok::Request.new(@api_url, token, @partner_id, @partner_secret)
      body = request.fetch(path, params)
      REXML::Document.new(body)
    end
  end
end
