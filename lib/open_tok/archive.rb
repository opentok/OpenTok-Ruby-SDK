=begin
 OpenTok Ruby Library v0.90.0
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.
=end

module OpenTok
  class Archive
    attr_accessor :archive_id, :archive_title, :resources, :timeline

    def initialize(archive_id, archive_title, resources, timeline)
      @archive_id = archive_id
      @archive_title = archive_title
      @resources = resources
      @timeline = timeline
    end

    def download_archive_url(video_id)
      "#{API_URL}/archive/url/#{@archive_id}/#{video_id}" 
    end

    def self.parse_manifest(manifest)
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

      OpenTok::Archive.new(archive_id, archive_title, resources, timeline)
    end
  end
end