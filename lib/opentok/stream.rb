require "active_support/inflector"

module OpenTok
  # Represents information about a stream in an OpenTok session.
  #
  # @attr [string] id
  #   The stream ID.
  #
  # @attr [string] name
  #   The name of the stream.

  # @attr [string] videoType
  #   The videoType property is either "camera" or "screen".
  #
  # @attr [array] layoutClassList
  #   An array of the layout classes for the stream.
  class Stream

    # @private
    def initialize(json)
      # TODO: validate json fits schema
      @json = json
    end

    # A JSON-encoded string representation of the stream.
    def to_json
      @json.to_json
    end


    # @private ignore
    def method_missing(method, *args, &block)
      camelized_method = method.to_s.camelize(:lower)
      if @json.has_key? camelized_method and args.empty?
        # TODO: convert create_time method call to a Time object
        if camelized_method == 'outputMode'
          @json[camelized_method].to_sym
        else
          @json[camelized_method]
        end
      else
        super method, *args, &block
      end
    end
  end
end
