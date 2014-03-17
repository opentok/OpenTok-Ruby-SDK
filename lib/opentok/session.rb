require "base64"
require "opentok/token_generator"

module OpenTok

  class Session

    # include TokenGenerator
    # generates_tokens :session_id => ->(instance) {
    #   instance.session_id
    # }


    attr_reader :session_id, :p2p, :location

    # this implementation doesn't completely understand the format of a Session ID
    # that is intentional, that is too much responsibility.
    def self.belongs_to_api_key?(session_id, api_key)
      encoded = session_id[2..session_id.length]
                          .gsub('-', '+')
                          .gsub('_', '/')
      decoded = Base64.decode64(encoded)
      decoded.include? api_key
    end

    attr_reader :session_id

    def initialize(api_key, api_secret, session_id, opts)
      @api_key, @api_secret, @session_id = api_key, api_secret, session_id
      @p2p, @location = opts[:p2p], opts[:location]
    end

    def to_s
      @session_id
    end
  end
end
