require "opentok/archive"

module OpenTok
  # A class for accessing an array of Archive objects.
  class ArchiveList < Array

    # The total number archives.
    attr_reader :total

    # @private
    def initialize(interface, json)
      @total = json['count']
      super json['items'].map { |item| Archive.new interface, item }
    end

  end
end
