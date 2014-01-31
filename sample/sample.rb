require 'opentok'

API_KEY = '472032'    # See https://dashboard.tokbox.com/
API_SECRET = '034de16b3e6a241bfbcaec45c0d1e79be19ad919' # See https://dashboard.tokbox.com/

OTSDK = OpenTok::OpenTokSDK.new API_KEY, API_SECRET

# Create an OpenTok server-enabled session
session_id = OTSDK.createSession().to_s
print session_id + "\n"

# Create a peer-to-peer session
session_properties = {OpenTok::SessionPropertyConstants::P2P_PREFERENCE => "enabled"}    # or disabled
session_id = OTSDK.createSession( nil, session_properties ).to_s
print session_id + "\n"

# Generate a publisher token
token = OTSDK.generateToken :session_id => session_id
print token + "\n"

# Generate a token with moderator role and connection data
role = OpenTok::RoleConstants::MODERATOR
connection_data = "username=Bob,level=4, score=8888888888"
token = OTSDK.generateToken :session_id => session_id, :role => role, :connection_data => connection_data
print token + "\n"

# Generate a token with moderator role and connection data
role = OpenTok::RoleConstants::MODERATOR
connection_data = "username=Bob,level=4, score=8888888888"
token = OTSDK.generateToken :session_id => session_id, :role => role, :connection_data => connection_data
print token + "\n"

# The following method starts recording an archive of an OpenTok 2.0 session
# and returns the archive ID (on success). Note that you can only start an archive
# on a session that has clients connected.

session_id = session_id # Replace with an OpenTok session ID.
name = "archive-" + Time.new.inspect
# archive_id = start_archive(session_id, name)

def start_archive (session_id, name)
  begin
    return OTSDK.archives.create(session_id, name)
  rescue Exception => msg
    print msg, "\n"
  end
end


# The following method stops the recording of an archive, returning
# true on success, and false on failure.

archive_id = "" # Replace with a valid archive ID.
#stop_archive(archive_id)

def stop_archive (archive_id)
  begin
    archive = OTSDK.archives.find(archive_id).stop
  rescue Exception => msg
    print msg, "\n"
  end
end

# The following method deletes a given archive.

archive_id = "" # Replace with a valid archive ID.
# delete_archive (archive_id)

def delete_archive (archive_id)
  archive = OTSDK.archives.find(archive_id).delete
end

# The following method logs information on a given archive.

archive_id = "" # Replace with a valid archive ID.
# get_archive_info (archive_id)

def get_archive_info (archive_id)
  begin
    archive = OTSDK.archives.find archive_id
    archive.each do |key, value|
      puts "#{key}: #{value}\n"
    end
  rescue Exception => msg
    print msg, "\n"
  end
end

# The following code logs the archive IDs of all archives (up to 1000)
# for your API key.

archive_list = OTSDK.archives.all
archive_list.each do |archive|
  print archive.id + "\n"
end