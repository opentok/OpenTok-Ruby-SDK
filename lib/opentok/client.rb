require "httparty"

module OpenTok
  class Client
    include HTTParty
    # debug_output $stdout

    def initialize(api_key, api_secret, api_url)
      self.class.base_uri api_url
      self.class.headers({ 
        "X-TB-PARTNER-AUTH" => "#{api_key}:#{api_secret}",
        "User-Agent" => "OpenTok-Ruby-SDK/#{VERSION}"
      })
    end

    def create_session(opts)
      # TODO: error handling
      self.class.post("/session/create", :body => self.class.transform_session_opts(opts))
    end

    def self.transform_session_opts(opts)
      opts["p2p.preference"] = opts.delete(:p2p) ? "enabled" : "disabled"
      opts
    end
  end
end
