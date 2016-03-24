module OpenTok
  module HashExtensions
    def camelize_keys!
      keys.each do |k|
        new_key = k.to_s.camelize(:lower)
        new_key = new_key.to_sym if k.is_a? Symbol
        self[new_key] = self.delete(k)
      end
      self
    end
  end
end
