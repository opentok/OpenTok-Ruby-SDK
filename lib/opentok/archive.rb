
module OpenTok
  class Archive < Hash

    def initialize(archives, archive)

      @archives = archives
      
      store = Hash.new

      archive.each do |key, value|
        store[underscore(key).to_sym] = if key == 'createdAt'
          Time.at(value / 1000)
        else
          value
        end
      end

      update store
    end

    def stop
      update @archives.stop_by_id id
    end

    def delete
      @archives.delete_by_id id
    end

    def []= (key, value)
      raise OpenTokError, "You cannot directly modify archive properties"
    end

    def size
      self[:size]
    end

      # Route get and set calls.
    def method_missing(sig, *args, &block)
      type = sig.to_s[-1,1]
      name = sig.to_s.sub(/[!?=]$/, '').to_sym
      case type
      when '='
        raise OpenTokError, "You cannot directly modify archive properties"
      when '?'
        key?(name)
      else
        if args.length == 0 && !block
          self[name]
        else
          super(sig, *args, &block)
        end
      end
    end

    protected

    def underscore(str)
      str.gsub(/::/, '/').
      gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
      gsub(/([a-z\d])([A-Z])/,'\1_\2').
      tr("-", "_").
      downcase
    end

  end
end
