module OpenTok
  API_URL = 'https://api.opentok.com'.freeze
  TOKEN_SENTINEL = 'T1=='.freeze
  ROLES = { subscriber: 'subscriber', publisher: 'publisher', moderator: 'moderator' }.freeze
  ARCHIVE_MODES = Set.new([:manual, :always])
end
