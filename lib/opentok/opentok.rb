require "opentok/constants"
require "opentok/session"
require "opentok/client"
require "opentok/token_generator"

require "resolv"

module OpenTok
  class OpenTok

    include TokenGenerator
    generates_tokens({
      :api_key => ->(instance) { instance.api_key },
      :api_secret => ->(instance) { instance.api_secret }
    })

    # don't want these to be mutable, may cause bugs related to inconsistency since these values are
    # cached in objects that this can create
    attr_reader :api_key, :api_secret, :api_url

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

      response = client.create_session(params.clone)
      Session.new @api_key, @api_secret, response['sessions']['Session']['session_id'], params
    end

    # def archives
    #   @archives ||= Archives.new @partner_id, @partner_secret, @api_url
    # end

    protected

    def client
      @client ||= Client.new @api_key, @api_secret, @api_url
    end

  end
end
