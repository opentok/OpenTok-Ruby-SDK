require "opentok/render"

module OpenTok
  # A class for accessing an array of Experience Composer Render objects.
  class RenderList < Array
    # The total number of Experience Composer renders.
    attr_reader :total

    def initialize(interface, json)
      @total = json["count"]
      super json["items"].map { |item| ::OpenTok::Render.new interface, item }
    end
  end
end
