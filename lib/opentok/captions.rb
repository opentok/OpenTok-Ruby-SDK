module OpenTok
  #  A class for working with OpenTok captions.
  class Captions
    # @private
    def initialize(client)
      @client = client
    end

    def start(session_id, token, options = {})
      @client.start_live_captions(session_id, token, options)
    end

    def stop(captions_id)
      @client.stop_live_captions(captions_id)
    end
  end
end
