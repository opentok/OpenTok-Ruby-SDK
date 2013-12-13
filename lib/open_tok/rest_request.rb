require 'json'
require 'rest_client'

module OpenTok
  class RestRequest

    def initialize(api_url, partner_id, partner_secret)
      raise ArgumentError, "No API URL provided" if api_url.nil?
      raise ArgumentError, "No Partner ID provided" if partner_id.nil?
      raise ArgumentError, "No Partner Secret provided" if partner_secret.nil?
      @server = api_url
      @partner = partner_id
      @secret = partner_secret
    end

    def get(url)
      full_url = "#{@server}/v2/partner/#{@partner}#{url}"
      opts = { 'X-TB-PARTNER-AUTH' => "#{@partner}:#{@secret}" }
      RestClient.get(full_url, opts) { |response, request, result, &block|
        if response.length > 2
          yield JSON.parse(response), response.code
        else
          yield nil, response.code
        end
      }
    end

    def put(url, body)
      full_url = "#{@server}/v2/partner/#{@partner}#{url}"
      opts = {  content_type: :json,  'X-TB-PARTNER-AUTH' => "#{@partner}:#{@secret}" }
      RestClient.put(full_url, body.to_json, opts) { |response, request, result, &block|
        if response.length > 2
          yield JSON.parse(response), response.code
        else
          yield nil, response.code
        end
      }
    end

    def post(url, body)
      full_url = "#{@server}/v2/partner/#{@partner}#{url}"
      opts = {  content_type: "application/json",  'X-TB-PARTNER-AUTH' => "#{@partner}:#{@secret}" }
      RestClient.post(full_url, body.to_json, opts) { |response, request, result, &block|
        if response.length > 2
          yield JSON.parse(response), response.code
        else
          yield nil, response.code
        end
      }
    end

    def delete(url)
      full_url = "#{@server}/v2/partner/#{@partner}#{url}"
      opts = { 'X-TB-PARTNER-AUTH' => "#{@partner}:#{@secret}" }
      RestClient.delete(full_url, opts) { |response, request, result, &block|
        if response.length > 2
          yield JSON.parse(response), response.code
        else
          yield nil, response.code
        end
      }
    end

  end
end
