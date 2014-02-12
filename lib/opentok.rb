=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010 - 2012, TokBox, Inc.

 Last modified: 2012-08-28
=end

require 'rubygems'

module OpenTok

  API_URL = 'http://api.opentok.com/hl'

  autoload :OpenTokSDK, 'open_tok/open_tok_sdk'
  autoload :RoleConstants, 'open_tok/role_constants'
  autoload :SessionPropertyConstants, 'open_tok/session_property_constants'

end
