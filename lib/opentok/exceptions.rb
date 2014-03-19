module OpenTok

  class OpenTokError < StandardError; end
  class OpenTokArchiveError < OpenTokError; end
  class OpenTokAuthenticationError < OpenTokError; end

end
