require "opentok/stream"


module OpenTok
  # A class for accessing a list of Stream objects.
  class StreamList < Array

    # The total number streams.
    attr_reader :total

    # @private
    def initialize(json)
      @total = json['count']
      super json['items'].map { |item| Stream.new item }
    end

  end
end