require "opentok/broadcast"

module OpenTok
  # A class for accessing an array of Broadcast objects.
  class BroadcastList < Array
    # The total number of broadcasts.
    attr_reader :total

    def initialize(interface, json)
      @total = json["count"]
      super json["items"].map { |item| ::OpenTok::Broadcast.new interface, item }
    end
  end
end
