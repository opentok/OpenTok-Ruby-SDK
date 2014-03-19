require "multi_json"
require "active_support/inflector"

module OpenTok
  class Archive

    def initialize(interface, json)
      @interface = interface
      # TODO: validate json fits schema
      @json = json
    end

    def stop
      # TODO: validate returned json fits schema
      @json = @interface.stop_by_id @json['id']
    end

    def delete
      # TODO: validate returned json fits schema
      @json = @interface.delete_by_id @json['id']
    end

    def method_missing(method, *args, &block)
      camelized_method = method.to_s.camelize(:lower)
      if @json.has_key? camelized_method and args.empty?
        # TODO: convert create_time method call to a Time object
        @json[camelized_method]
      else
        super method, *args, &block
      end
    end
  end
end
