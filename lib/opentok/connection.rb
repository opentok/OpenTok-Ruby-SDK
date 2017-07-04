require "opentok/client"
require "opentok/archive"
require "opentok/archive_list"

module OpenTok
  # A class for working with OpenTok connections.
  class Connection

    # @private
    def initialize(client)
      @client = client
    end

    # Force disconnects an OpenTok connection.
    #
    # @param [String] session_id The session ID of the connection you want to disconect.
    # @param [String] connection_id The connection ID of the connection you want to disconect.
    #
    # @raise [OpenTokAuthenticationError] Authentication failed.
    # @raise [OpenTokError] The session ID/connection ID is invalid or does not exist.
    def delete_by_id(session_id, connection_id)
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      raise ArgumentError, "connection_id not provided" if connection_id.to_s.empty?
      response = @client.disconnection_connection(session_id, connection_id)
      (200..300).include? response.code
    end

  end
end
