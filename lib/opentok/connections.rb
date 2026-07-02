require "opentok/client"
require "opentok/connection"
require "opentok/connection_list"

module OpenTok
  #  A class for working with OpenTok connections.
  class Connections
    # @private
    def initialize(client)
      @client = client
    end

    # Returns a ConnectionList, which is an array of connections that are active in a session,
    # for your API key.
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [Hash] options  A hash with keys defining which range of connections to retrieve.
    # @option options [integer] :offset Optional. The index offset of the first connection. If you do not specify an offset, 0 is used.
    # @option options [integer] :count Optional. The number of connections to be returned. The maximum
    #   number of connections returned is 1000. If you do not specify a count, 50 is used.
    #
    # @return [ConnectionList] A ConnectionList object, which is an array of Connection objects.
    def list(session_id, options = {})
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      raise ArgumentError, "count must be between 1 and 1000" if options[:count] && (options[:count] < 1 || options[:count] > 1000)
      connections_list_json = @client.list_connections(session_id, options[:offset], options[:count])
      ConnectionList.new self, connections_list_json
    end

    # Force a client to disconnect from an OpenTok session.
    #
    # A client must be actively connected to the OpenTok session for you to disconnect it.
    #
    # @param [String] session_id The session ID of the OpenTok session.
    # @param [String] connection_id The connection ID of the client in the session.
    #
    # @raise [ArgumentError] The connection_id or session_id is invalid.
    # @raise [OpenTokAuthenticationError] You are not authorized to disconnect the connection. Check your authentication credentials.
    # @raise [OpenTokConnectionError] The client specified by the connection_id  property is not connected to the session.
    #
    def forceDisconnect(session_id, connection_id)
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      raise ArgumentError, "connection_id not provided" if connection_id.to_s.empty?
      response = @client.forceDisconnect(session_id, connection_id)
      (200..300).include? response.code
    end

  end
end
