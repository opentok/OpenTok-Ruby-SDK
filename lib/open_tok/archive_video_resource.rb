=begin
 OpenTok Ruby Library v0.90.0
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.
=end

module OpenTok
  class ArchiveVideoResource
    attr_reader :type
    attr_accessor :id, :length

    def initialize(id, length)
      @id = id
      @type = "video"
      @length = length
    end

    def getId
      return @id
    end

    def self.parseXML(video_resource_item)
      ArchiveVideoResource.new video_resource_item.attributes['id'], video_resource_item.attributes['length']
    end
  end

end
