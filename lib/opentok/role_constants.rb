module OpenTok

  # * +SUBSCRIBER+ Can only subscribe
  # * +PUBLISHER+ Can publish, subscribe, and signal
  # * +MODERATOR+ Can do the above along with forceDisconnect and forceUnpublish
  module RoleConstants
    SUBSCRIBER = "subscriber" # Can only subscribe
    PUBLISHER = "publisher"   # Can publish, subscribe, and signal
    MODERATOR = "moderator"   # Can do the above along with  forceDisconnect and forceUnpublish

    class << self
      def is_valid?(role)
        role == SUBSCRIBER || role == PUBLISHER || role == MODERATOR
      end
    end
  end

end