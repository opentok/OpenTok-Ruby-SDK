=begin
 OpenTok Ruby Library v0.90.0
 http://www.tokbox.com/

 Copyright 2010 - 2011, TokBox, Inc.
=end

module OpenTok
  class ArchiveTimelineEvent
    attr_accessor :event_type, :resource_id, :offset

    def initialize(event_type, resource_id, offset)
      @event_type = event_type
      @resource_id = resource_id
      @offset = offset
    end

    def self.parseXML(timeline_item)
      OpenTok::ArchiveTimelineEvent.new timeline_item.attributes['type'], timeline_item.attributes['id'], timeline_item.attributes['offset']
    end
  end
end
