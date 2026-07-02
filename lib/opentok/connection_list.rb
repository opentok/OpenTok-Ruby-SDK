require "opentok/connection"

module OpenTok
  # A class for accessing an array of Connection objects.
  class ConnectionList < Array

    # `total`: The total number of connections.
    # `session_id`: The session ID of the session these connections belong to.
    attr_reader :total, :session_id

    # @private
    def initialize(interface, json)
      @total = json['count']
      @session_id = json['sessionId']
      super json['items'].map { |item| Connection.new interface, session_id, item }
    end

  end
end
