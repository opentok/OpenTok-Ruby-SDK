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
      Request.new(@api_url, token).fetch(path)
    end

    def download_archive_url(video_id, token="")
      if token.empty?
        # this token check supports previous implementation of download_archive_url
        "#{@api_url}/archive/url/#{@archive_id}/#{video_id}"
      else
        do_request "/archive/url/#{@archive_id}/#{video_id}", token
      end
    end

    alias_method :downloadArchiveURL, :download_archive_url

    def self.parse_manifest(manifest, api_url, token)
      archive_id = manifest.attributes['archiveid']
      archive_title = manifest.attributes['title']

      resources = []
      manifest.get_elements('resources')[0].get_elements('video').each do |video|
        resources << ArchiveVideoResource.parseXML(video)
      end

      timeline = []
      manifest.get_elements('timeline')[0].get_elements('event').each do |event|
        timeline << ArchiveTimelineEvent.parseXML(event)
      end

      Archive.new archive_id, archive_title, resources, timeline, api_url, token
    end
  end
end
