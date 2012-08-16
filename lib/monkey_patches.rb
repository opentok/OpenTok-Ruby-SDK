=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.

 Last modified: 2011-02-17
=end

class Net::HTTP
  alias_method :old_initialize, :initialize
  def initialize(*args)
    old_initialize(*args)
    @ssl_context = OpenSSL::SSL::SSLContext.new
    @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end
end
