require "opentok/client"

# An object that lets you use the OpenTok SIP gateway.
module OpenTok
  class Sip
    # Dials a SIP gateway to input an audio-only stream into your OpenTok session.
    # See the {https://tokbox.com/developer/guides/sip/ OpenTok SIP developer guide}.
    #
    # @example
    #    opts = { "from" => "14155550101@example.com",
    #      "auth" => { "username" => sip_username,
    #        "password" => sip_password },
    #      "headers" => { "X-KEY1" => "value1",
    #        "X-KEY1" => "value2" },
    #      "secure" => "true"
    #    }
    #    response = opentok.sip.dial(session_id, token, "sip:+15128675309@acme.pstn.example.com;transport=tls", opts)
    # @param [String] session_id The session ID corresponding to the session to which
    #   the SIP gateway will connect.
    # @param [String] token The token for the session ID with which the SIP user
    #   will use to connect.
    # @param [String] sip_uri The SIP URI the OpenTok SIP gateway will dial.
    # @param [Hash] opts A hash defining options for the SIP call. For example:
    # @option opts [String] :from The number or string that will be sent to the final
    #   SIP number as the caller. It must be a string in the form of "from@example.com",
    #   where from can be a string or a number. If from is set to a number
    #   (for example, "14155550101@example.com"), it will show up as the incoming
    #   number on PSTN phones. If from is undefined or set to a string (for example,
    #   "joe@example.com"), +00000000 will show up as the incoming number on
    #   PSTN phones.
    # @option opts [Hash] :headers This hash defines custom headers to be added
    #   to the SIP ​INVITE​ request initiated from OpenTok to the your SIP platform.
    #   Each of the custom headers must start with the ​"X-"​ prefix, or the call
    #   will result in a Bad Request (400) response.
    # @option opts [Hash] :auth This object contains the username and password
    #   to be used in the the SIP INVITE​ request for HTTP digest authentication,
    #   if it is required by your SIP platform.
    # @option opts  [true, false] :secure Wether the media must be transmitted
    #   encrypted (​true​) or not (​false​, the default).
    def dial(session_id, token, sip_uri, opts)
      response = @client.dial(session_id, token, sip_uri, opts)
    end

    def initialize(client)
      @client = client
    end
  end
end
