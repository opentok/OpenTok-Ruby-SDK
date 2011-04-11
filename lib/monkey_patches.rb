=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010, TokBox, Inc.

 Last modified: 2011-02-17
=end

class Hash

  # Adding a urlencode method to the hash class for easy querstring generation
  def urlencode
    to_a.map do |name_value|
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

class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end
