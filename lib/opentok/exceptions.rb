module OpenTok

  # Defines errors raised by methods of the OpenTok Ruby SDK.
  class OpenTokError < StandardError; end
  # Defines errors raised by archive-related methods of the OpenTok Ruby SDK.
  class OpenTokArchiveError < OpenTokError; end
  # Defines errors raised by SIP methods of the OpenTok Ruby SDK.
  class OpenTokSipError < OpenTokError; end
  # Defines errors raised when you attempt an operation using an invalid OpenTok API key or secret.
  class OpenTokAuthenticationError < OpenTokError; end
  # Defines errors raised when you attempt a force disconnect a client and it is not connected to the session.
  class OpenTokConnectionError < OpenTokError; end
  # Defines errors raised when you attempt set layout classes to a stream.
  class OpenTokStreamLayoutError < OpenTokError; end
  # Defines errors raised when you perform Broadcast operations.
  class OpenTokBroadcastError < OpenTokError; end
  # Defines errors raised when connecting to WebSocket URIs.
  class OpenTokWebSocketError < OpenTokError; end
  # Defines errors raised when you perform Experience Composer render operations.
  class OpenTokRenderError < OpenTokError; end
end
