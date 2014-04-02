=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.

=end

module OpenTok

  # The exception that gets thrown when an invalid api-key and/or secret is given.
  class OpenTokException < RuntimeError

    def initialize(message)
      @mesasge = message
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
        exception ||= self
        message = child.children.empty? ? '' : child.children[0].attributes['message']
        exception.new message
      end

      # To be overriden by subclasses
      def http_code
        '000'
      end
    end

  end

  class OpenTokNotFound < OpenTokException
    def self.http_code
      '404'
    end
  end

end
