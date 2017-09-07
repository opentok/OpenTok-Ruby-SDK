module OpenTok
  API_URL = "https://api.opentok.com"
  TOKEN_SENTINEL = "T1=="
  ROLES = { subscriber: "subscriber", publisher: "publisher", moderator: "moderator" }
  ARCHIVE_MODES = Set.new([:manual, :always])
  AUTH_EXPIRE = 300
end
