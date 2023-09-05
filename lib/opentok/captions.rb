module OpenTok
  #  A class for working with OpenTok captions.
  class Captions
    # @private
    def initialize(client)
      @client = client
    end

    # Starts live captions for the specified OpenTok session.
    # See the {https://tokbox.com/developer/guides/live-captions/ OpenTok Live Captions developer guide}.
    #
    # @example
    #    opts = { "language_code" => "en-GB",
    #             "max_duration" => 5000,
    #             "partial_captions" => false,
    #             "status_callback_url" => status_callback_url
    #           }
    #    response = opentok.captions.start(session_id, token, opts)
    #
    # @param [String] session_id The session ID corresponding to the session for which captions will start.
    # @param [String] token The token for the session ID with which the SIP user will use to connect.
    # @param [Hash] options A hash defining options for the captions. For example:
    # @option options [String] :language_code The BCP-47 code for a spoken language used on this call.
    #   The default value is "en-US". The following language codes are supported:
    #     - "en-AU" (English, Australia)
    #     - "en-GB" (Englsh, UK)
    #     - "es-US" (English, US)
    #     - "zh-CN” (Chinese, Simplified)
    #     - "fr-FR" (French)
    #     - "fr-CA" (French, Canadian)
    #     - "de-DE" (German)
    #     - "hi-IN" (Hindi, Indian)
    #     - "it-IT" (Italian)
    #     - "ja-JP" (Japanese)
    #     - "ko-KR" (Korean)
    #     - "pt-BR" (Portuguese, Brazilian)
    #     - "th-TH" (Thai)
    # @option options [Integer] :max_duration The maximum duration for the audio captioning, in seconds.
    #   The default value is 14,400 seconds (4 hours), the maximum duration allowed.
    # @option options [Boolean] :partial_captions Whether to enable this to faster captioning at the cost of some
    #   degree of inaccuracies. The default value is `true`.
    # @option options [String] :status_callback_url A publicly reachable URL controlled by the customer and capable
    #   of generating the content to be rendered without user intervention. The minimum length of the URL is 15
    #   characters and the maximum length is 2048 characters.
    #   For more information, see {https://tokbox.com/developer/guides/live-captions/#live-caption-status-updates Live Caption status updates}.
    def start(session_id, token, options = {})
      @client.start_live_captions(session_id, token, options)
    end

    # Starts live captions for the specified OpenTok session.
    # See the {https://tokbox.com/developer/guides/live-captions/ OpenTok Live Captions developer guide}.
    #
    # @example
    #    response = opentok.captions.stop(captions_id)
    #
    # @param [String] captions_id The ID for the captions to be stopped (returned from the `start` request).
    def stop(captions_id)
      @client.stop_live_captions(captions_id)
    end
  end
end
