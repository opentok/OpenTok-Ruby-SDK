=begin
 OpenTok Ruby Library v0.90.0
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.
=end

module OpenTok
  class Archive
    attr_accessor :archive_id, :archive_title, :resources, :timeline

    def initialize(archive_id, archive_title, resources, timeline, apiUrl, token)
      @archive_id = archive_id
      @archive_title = archive_title
      @resources = resources
      @timeline = timeline
      @apiUrl = apiUrl
      @token = token
    end

    def do_request(api_url)
      url = URI.parse(api_url)
      req = Net::HTTP::Get.new(url.path)

      req.add_field 'X-TB-TOKEN-AUTH', @token

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if @apiUrl.start_with?("https")
      res = http.start {|http| http.request(req)}
      case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        return res.read_body
      else
        res.error!
      end
    rescue Net::HTTPExceptions
      raise
      raise OpenTokException.new 'Unable to create fufill request: ' + $!
    rescue NoMethodError
      raise
      raise OpenTokException.new 'Unable to create a fufill request at this time: ' + $1
    end

    def download_archive_url(video_id)
      doc = do_request "#{@apiUrl}/archive/url/#{@archive_id}/#{video_id}" 
      if not doc.get_elements('Errors').empty?
        raise OpenTokException.new doc.get_elements('Errors')[0].get_elements('error')[0].children.to_s
      end
      doc
    end

    def downloadArchiveURL(video_id)
      doc = do_request "#{@apiUrl}/archive/url/#{@archive_id}/#{video_id}" 
      return doc
    end

    def self.parse_manifest(manifest, apiUrl, token)
      archive_id = manifest.attributes['archiveid']
      archive_title = manifest.attributes['title']

      resources = []
      manifest.get_elements("resources")[0].get_elements("video").each do |video|
        resources << OpenTok::ArchiveVideoResource.parseXML(video)
      end

      timeline = []
      manifest.get_elements("timeline")[0].get_elements("event").each do |event|
        timeline << OpenTok::ArchiveTimelineEvent.parseXML(event)
      end

      OpenTok::Archive.new(archive_id, archive_title, resources, timeline, apiUrl, token)
    end
  end
end
