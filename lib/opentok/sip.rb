require "opentok/client"

module OpenTok
  class Sip
    def dial(session_id, token, sip_uri, opts)
      response = @client.dial(session_id, token, sip_uri, opts)
    end

    def initialize(client)
      @client = client
    end
  end
end
