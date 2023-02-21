require "opentok/client"

# An object that lets you work with Audio Connector WebSocket connections.
module OpenTok
  class WebSocket
    # Starts an Audio Connector WebSocket connection to send audio from a Vonage Video API session to a WebSocket URI.
    # See the {https://tokbox.com/developer/guides/audio-connector/ OpenTok Audio Connector developer guide}.
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
    # @param [String] session_id (required) The OpenTok session ID that includes the OpenTok streams you want to include in
    #       the WebSocket stream.
    # @param [String] token (required) The OpenTok token to be used for the Audio Connector connection to the. OpenTok session.
    # @param [String] websocket_uri (required) A publicly reachable WebSocket URI to be used for the destination of the audio
    #       stream (such as "wss://service.com/ws-endpoint").
    # @param [Hash] opts (optional) A hash defining options for the Audio Connector WebSocket connection. For example:
    # @option opts [Array] :streams (optional) An array of stream IDs for the OpenTok streams you want to include in the WebSocket stream.
    #       If you omit this property, all streams in the session will be included.
    # @option opts [Hash] :headers (optional) A hash of key-value pairs of headers to be sent to your WebSocket server with each message,
    #        with a maximum length of 512 bytes.
    def connect(session_id, token, websocket_uri, opts  = {})
      response = @client.connect_websocket(session_id, token, websocket_uri, opts)
    end

    def initialize(client)
      @client = client
    end
  end
end
