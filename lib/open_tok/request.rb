require 'uri'
require 'net/http'
require 'net/https'

Net::HTTP.version_1_2 # to make sure version 1.2 is used

module OpenTok
  class Request

    def initialize(api_host, token, partner_id = nil, partner_secret = nil)
      @api_host       = api_host
      @token          = token
      @partner_id     = partner_id
      @partner_secret = partner_secret
    end

    def sendRequest(path, params)
      url = URI.parse(@api_host + path)

      if params.nil? || params.empty?
        req = Net::HTTP::Get.new url.path
      else
        req = Net::HTTP::Post.new url.path
        req.set_form_data(params)
      end

      req = set_headers(req)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = @api_host.start_with?("https")
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT

      http.start {|h| h.request(req) }
    end

    def fetch(path, params={})
      res = sendRequest path, params

      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        return res.read_body
      else
        res.error!
      end

    rescue Net::HTTPExceptions => e
      raise OpenTokException.new e.response.code, "Unable to create fufill request: #{e}"
    rescue NoMethodError => e
      raise OpenTokException.new e.response.code, "Unable to create a fufill request at this time: #{e}"
    end

    private

    def set_headers(req)
      if @token
        req.add_field 'X-TB-TOKEN-AUTH', @token
      elsif @partner_id && @partner_secret
        req.add_field 'X-TB-PARTNER-AUTH', "#{@partner_id}:#{@partner_secret}"
      end
      req
    end
  end
end
