require "opentok/archive"

require "multi_json"

module OpenTok
  class ArchiveList < Array

    attr_reader :total

    def initialize(interface, json)
      @total = json['count']
      super json['items'].map { |item| Archive.new interface, item }
    end

  end
end
