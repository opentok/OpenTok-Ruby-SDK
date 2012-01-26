=begin
 OpenTok Ruby Library v0.90.0
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.
=end

module OpenTok
  
  # The session object that contains the session_id
  class Session
    attr_reader :session_id

    def initialize(session_id)
      @session_id     = session_id
    end

    def to_s
      session_id
    end
  end
end
