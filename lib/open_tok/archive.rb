=begin
 OpenTok Ruby Library v0.90.0
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.
=end

module OpenTok
  class Archive
    attr_accessor :archive_id, :archive_title, :resources, :timeline

    def initialize(archive_id, archive_title, resources, timeline, api_url, token)
      @archive_id = archive_id
      @archive_title = archive_title
      @resources = resources
      @timeline = timeline
      @api_url = api_url
      @token = token
    end

    def do_request(path, token)
      OpenTok::Request.new(@api_url, token).fetch(path)
    end

    def download_archive_url(video_id, token="")
      if token==""
        # this token check supports previous implementation of download_archive_url
        return "#{@api_url}/archive/url/#{@archive_id}/#{video_id}"
      else
        doc = do_request "/archive/url/#{@archive_id}/#{video_id}", token
        if not doc.get_elements('Errors').empty?
          raise OpenTokException.new doc.get_elements('Errors')[0].get_elements('error')[0].children.to_s
        end
        return doc
      end
    end
    alias_method :downloadArchiveURL, :download_archive_url

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
