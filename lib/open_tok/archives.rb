module OpenTok
  class Archives

    def initialize(partner_id, partner_secret, api_url = OpenTok::API_URL)
      @partner_id = partner_id.to_s()
      @partner_secret = partner_secret
      @api_url = api_url
    end

    def request
      @request ||= RestRequest.new(@api_url, @partner_id, @partner_secret)
    end

    def create(session_id, options = {})
      raise ArgumentError, "session_id not provied" if session_id.nil? or session_id.to_s.length == 0

      name = if options.is_a?(Hash) and options['name'] or options[:name]
        options[:name] or options['name']
      end

      request.post("/archive", :action => :start, :sessionId => session_id, :name => name) do |response, code|
        if code < 300
          Archive.new self, response
        elsif code == 400
          raise OpenTokException.new code, "Session is invalid"

        elsif code == 403
          raise OpenTokAuthenticationError

        elsif code == 404
          raise OpenTokSessionNotFoundError

        elsif code == 409
          raise OpenTokConflictError, response["message"]

        elsif code
          raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"

        end
      end

    end

    def find(archive_id)
      raise ArgumentError, "archive_id not provied" if archive_id.nil? or archive_id.to_s.length == 0

      request.get("/archive/#{archive_id}") do |response, code|
        if code < 300
          Archive.new self, response

        elsif code == 403
          raise OpenTokAuthenticationError

        elsif code == 404
          raise OpenTokArchiveNotFoundError

        else
          raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"

        end
      end

    end

    def all(options = {})
      args = "offset=" + (options[:offset] || options['offset']).to_i.to_s
      count = options[:limit] || options['limit']
      unless count.nil?
        count = count.to_i
        raise ArgumentError, "Limit is invalid" unless count > 0 && count < 1000
        args = args + "&count=" + count.to_s
      end

      request.get("/archive?#{args}") do |response, code|
        if code < 300
          ArchiveList.new self, response

        elsif code == 403
          raise OpenTokAuthenticationError

        else
          raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"
        end

      end
    end

    def stop_by_id(archive_id)
      request.post("/archive/#{archive_id}", :action => :stop) do |response, code|
        if code < 300
          Archive.new self, response

        elsif code == 403
          raise OpenTokAuthenticationError

        elsif code == 404
          raise OpenTokArchiveNotFoundError

        elsif code == 409
          raise OpenTokNotArchivingError

        else
          raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"

        end
      end
    end

    def delete_by_id(archive_id)
      request.delete("/archive/#{archive_id}") do |response, code|
        if code < 300
          true

        elsif code == 403
          raise OpenTokAuthenticationError

        elsif code == 404
          raise OpenTokArchiveNotFoundError

        else
          raise OpenTokUnexpectedError.new code, response && response["message"] || "Unexpected server error"

        end
      end
    end

  end
end
