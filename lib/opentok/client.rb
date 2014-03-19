require "httparty"

module OpenTok
  class Client
    include HTTParty
    debug_output $stdout

    def initialize(api_key, api_secret, api_url)
      self.class.base_uri api_url
      self.class.headers({ 
        "X-TB-PARTNER-AUTH" => "#{api_key}:#{api_secret}",
        "User-Agent" => "OpenTok-Ruby-SDK/#{VERSION}"
      })
      @api_key = api_key
    end

    def create_session(opts)
      # TODO: error handling
      self.class.post("/session/create", :body => opts)
    end

    def start_archive(session_id, opts)
      # TODO: error handling
      body = { "sessionId" => session_id, "action" => "start" }
      body["name"] = opts[:name] unless opts[:name].nil?
      self.class.post("/v2/partner/#{@api_key}/archive", {
        :body => body.to_json,
        :headers => { "Content-Type" => "application/json" }
      })
    end

    def get_archive(archive_id)
      # TODO: error handling
      self.class.get("/v2/partner/#{@api_key}/archive/#{archive_id}")
    end

    def list_archives(offset, count)
      # TODO: error handling
      query = Hash.new
      query[:offset] = offset unless offset.nil?
      query[:count] = count unless count.nil?
      self.class.get("/v2/partner/#{@api_key}/archive", {
        :query => query
      })
    end

    def stop_archive(archive_id)
      # TODO: error handling
      self.class.post("/v2/partner/#{@api_key}/archive/#{archive_id}", {
        :body => { "action" => "stop" }.to_json,
        :headers => { "Content-Type" => "application/json" }
      })
    end

    def delete_archive(archive_id)
      # TODO: error handling
      self.class.delete("/v2/partner/#{@api_key}/archive/#{archive_id}", {
        :headers => { "Content-Type" => "application/json" }
      })
    end

  end
end
