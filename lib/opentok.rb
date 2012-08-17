=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.

 Last modified: 2011-02-17
=end

module OpenTok
  require 'rubygems'

  VERSION = "tbrb-v0.91.2011-02-17"
  API_URL = "https://staging.tokbox.com/hl"
  API_URL_PROD = 'https://api.opentok.com/hl'

  require 'open_tok/exception'
  require 'open_tok/utils'
  require 'open_tok/request'
  require 'open_tok/open_tok_sdk'
  require 'open_tok/session'
  require 'open_tok/archive'
  require 'open_tok/archive_video_resource'
  require 'open_tok/archive_timeline_event'
end
