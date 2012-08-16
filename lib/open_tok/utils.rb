require 'cgi'

module OpenTok
  module Utils
    # would recommend using `addressable` gem instead
    def self.urlencode_hash(hash)
      hash.to_a.map do |name_value|
        if name_value[1].is_a? Array
          name_value[0] = CGI.escape name_value[0].to_s
          name_value[1].map { |e| CGI.escape e.to_s }
          name_value[1] = name_value[1].join "&" + name_value[0] + "="
          name_value.join '='
        else
          name_value.map { |e| CGI.escape e.to_s }.join '='
        end
      end.join '&'
    end
  end
end