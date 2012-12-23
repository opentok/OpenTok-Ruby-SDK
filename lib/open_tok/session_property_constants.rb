
module OpenTok

  ##
  # Preferences that could be defined while creating a session
  module SessionPropertyConstants

    # @deprecated (feature deleted in OpenTok v0.91.48)
    # @param [Boolean]
    ECHOSUPPRESSION_ENABLED = 'echoSuppression.enabled'

    # @deprecated (feature deleted in OpenTok v0.91.48)
    # @param [Integer]
    MULTIPLEXER_NUMOUTPUTSTREAMS = 'multiplexer.numOutputStreams'

    # @deprecated (feature deleted in OpenTok v0.91.48)
    # @param [Integer]
    MULTIPLEXER_SWITCHTYPE = 'multiplexer.switchType'

    # @deprecated (feature deleted in OpenTok v0.91.48)
    # @param [Integer]
    MULTIPLEXER_SWITCHTIMEOUT = 'multiplexer.switchTimeout'

    # Whether the session's streams will be transmitted directly between peers
    # @param [disabled, enabled]
    P2P_PREFERENCE = 'p2p.preference'

  end

end