require 'opentok'

require 'vcr'
require 'webmock'

VCR.configure do |c|
  c.cassette_library_dir     = 'spec/cassettes'
  c.hook_into                :webmock
  c.default_cassette_options = { :record => :new_episodes }
  c.allow_http_connections_when_no_cassette=true
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end
