
module OpenTok
  class ArchiveList < Array

    attr_reader :total

    def initialize(api, response)
      @total = response['count']

      mapped =  response['items'].map do |item|
        Archive.new api, item
      end

      super mapped
    end
    
  end
end
