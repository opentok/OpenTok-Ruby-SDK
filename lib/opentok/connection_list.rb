require "opentok/connection"

module OpenTok
  # A class for accessing an array of Connection objects.
  class ConnectionList < Array

    # The total number of connections.
    attr_reader :total, :session_id

    # @private
    def initialize(interface, json)
      @total = json['count']
      @session_id = json['sessionId']
      super json['items'].map { |item| Connection.new interface, session_id, item }
    end

  end
end
