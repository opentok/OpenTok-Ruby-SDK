require "opentok/client"

# An object that lets you use the OpenTok SIP gateway.
module OpenTok
  class WebSocket
    # Dials a SIP gateway to input an audio-only stream into your OpenTok session.
    # See the {https://tokbox.com/developer/guides/sip/ OpenTok SIP developer guide}.
    #
    # @example
    #    opts = {
    #      "streams" => ["STREAMID1", "STREAMID2"],
    #      "headers" => {
    #        "key1" => "val1",
    #        "key2" => "val2"
    #      }
    #    }
    #    response = opentok.websocket.connect(SESSIONID, TOKEN, "ws://service.com/wsendpoint", opts)
    #
    # @param [String] session_id The session ID corresponding to the session to which
    #   the SIP gateway will connect.
    # @param [String] token The token for the session ID with which the SIP user
    #   will use to connect.
    # @param [String] websocket_uri The SIP URI the OpenTok SIP gateway will dial.
    # @param [Hash] opts A hash defining options for the SIP call. For example:
    # @option opts [Array] :streams The stream IDs of the participants' whose audio is going to be connected.
    #   If not provided, all streams in session will be selected.
    # @option opts [Hash] :headers A hash of key/val pairs with additional properties to send to your
    #   Websocket server, with a maximum length of 512 bytes.
    def connect(session_id, token, websocket_uri, opts  = {})
      response = @client.connect_websocket(session_id, token, websocket_uri, opts)
    end

    def initialize(client)
      @client = client
    end
  end
end
