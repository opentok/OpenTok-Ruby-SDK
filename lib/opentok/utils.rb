require 'addressable/uri'

module OpenTok
  module Utils
    def self.urlencode_hash(hash)
      uri = Addressable::URI.new :query_values => hash
      uri.query
    end
  end
end