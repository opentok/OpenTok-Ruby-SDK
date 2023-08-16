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
    #      "secure" => "true",
    #      "video" => "true",
    #      "observe_force_mute" => "true"
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
    # @option opts [Hash] :auth This object contains the username and password
    #   to be used in the the SIP INVITE​ request for HTTP digest authentication,
    #   if it is required by your SIP platform.
    # @option opts  [true, false] :secure Whether the media must be transmitted
    #   encrypted (​true​) or not (​false​, the default).
    # @option opts  [true, false] :video Whether the SIP call will include
    #  video (​true​) or not (​false​, the default). With video included, the SIP
    #  client's video is included in the OpenTok stream that is sent to the
    #  OpenTok session. The SIP client will receive a single composed video of
    #  the published streams in the OpenTok session.
    # @option opts  [true, false] :observe_force_mute Whether the SIP end point
    #  observes {https://tokbox.com/developer/guides/moderation/#force_mute force mute moderation}
    #  (true) or not (false, the default).
    # @option opts [Array] :streams An array of stream IDs for streams to include in the SIP call.
    #   If you do not set this property, all streams in the session are included in the call.
    def dial(session_id, token, sip_uri, opts)
      response = @client.dial(session_id, token, sip_uri, opts)
    end

    # Sends DTMF digits to a specific client connected to an OpnTok session.
    #
    # @param [String] session_id The session ID.
    # @param [String] connection_id The connection ID of the specific connection that
    # the DTMF signal is being sent to.
    # @param [String] dtmf_digits The DTMF digits to send. This can include 0-9, "*", "#", and "p".
    # A p indicates a pause of 500ms (if you need to add a delay in sending the digits).
    def play_dtmf_to_connection(session_id, connection_id, dtmf_digits)
      raise ArgumentError, "invalid DTMF digits" unless dtmf_digits_valid?(dtmf_digits)
      response = @client.play_dtmf_to_connection(session_id, connection_id, dtmf_digits)
    end

    # Sends DTMF digits to all clients connected to an OpnTok session.
    #
    # @param [String] session_id The session ID.
    # @param [String] dtmf_digits The DTMF digits to send. This can include 0-9, "*", "#", and "p".
    # A p indicates a pause of 500ms (if you need to add a delay in sending the digits).
    def play_dtmf_to_session(session_id, dtmf_digits)
      raise ArgumentError, "invalid DTMF digits" unless dtmf_digits_valid?(dtmf_digits)
      response = @client.play_dtmf_to_session(session_id, dtmf_digits)
    end

    def initialize(client)
      @client = client
    end

    private

    def dtmf_digits_valid?(dtmf_digits)
      dtmf_digits.match?(/^[0-9*#p]+$/)
    end
  end
end
