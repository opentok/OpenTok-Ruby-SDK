=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.

=end

module OpenTok

  # The exception that gets thrown when an invalid api-key and/or secret is given.
  class OpenTokException < RuntimeError

    attr_reader :code

    def initialize(code, message)
      @code = code
      @mesasge = message
      super message
    end

    class << self
      def inherited(subclass)
        exceptions << subclass
      end

      def exceptions
        @exceptions ||= []
      end

      ##
      # Generates the relevant exception instance based on the XML error data received
      def from_error(error)
        child = error.get_elements('Errors')[0].get_elements('error')[0]
        code = child.attributes['code']
        exception = exceptions.find{|exc| exc.http_code == code }
        exception ||= self
        message = child.children.empty? ? '' : child.children[0].attributes['message']
        exception.new code, message
      end

      # To be overriden by subclasses
      def http_code
        '000'
      end

    end

  end

  class OpenTokSessionNotFoundError < OpenTokException
    def initialize
      super 404, "Session not found"
    end
  end

  class OpenTokAuthenticationError < OpenTokException
    def initialize
      super 403, "Invalid Partner ID or Secret"
    end
  end

  class OpenTokConflictError < OpenTokException
    def initialize(message)
      super 409, message
    end
  end

  class OpenTokUnexpectedError < OpenTokException
    def initialize(code, message)
      super code, message || "Unexpected error"
    end
  end

  class OpenTokArchiveNotFoundError < OpenTokException
    def initialize
      super 404, "Archive not found"
    end
  end

  class OpenTokNotArchivingError < OpenTokException
    def initialize
      super 409, "Archive is not currently recording"
    end
  end

  class OpenTokNotFound < OpenTokException
    def self.http_code
      '404'
    end
  end

end
