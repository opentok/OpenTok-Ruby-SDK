=begin
 OpenTok Ruby Library
 http://www.tokbox.com/

 Copyright 2010 - 2012, TokBox, Inc.

 Last modified: 2012-08-28
=end

module OpenTok
  require 'rubygems'

  VERSION = "tbrb-v0.91.2012-08-28"
  API_URL = "https://api.opentok.com"

  require 'open_tok/exception'
  require 'open_tok/utils'
  require 'open_tok/request'
  require 'open_tok/open_tok_sdk'
  require 'open_tok/session'
  require 'open_tok/archive'
  require 'open_tok/archive_video_resource'
  require 'open_tok/archive_timeline_event'
end
