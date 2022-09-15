require "opentok/client"
require "opentok/render"
require "opentok/render_list"

module OpenTok
  # A class for working with OpenTok Experience Composer renders.
  # See {https://tokbox.com/developer/guides/experience-composer/ Experience Composer}.
  class Renders

    # @private
    def initialize(client)
      @client = client
    end

    # Starts an Experience Composer render for an OpenTok session.
    #
    # @param [String] session_id (Required) The session ID of the OpenTok session that will include the Experience Composer stream.
    #
    # @param [Hash] options (Required) A hash defining options for the render.
    #
    # @option options [String] :token (Required) A valid OpenTok token with a Publisher role and (optionally) connection data to be associated with the output stream.
    #
    # @option options [String] :url (Required) A publicly reachable URL controlled by the customer and capable of generating the content to be rendered without user intervention.
    #   The minimum length of the URL is 15 characters and the maximum length is 2048 characters.
    #
    # @option options [Integer] :max_duration (Optional) The maximum time allowed for the Experience Composer, in seconds. After this time, it is stopped 
    #   automatically, if it is still running. The maximum value is 36000 (10 hours), the minimum value is 60 (1 minute), and the default value is 7200 (2 hours). 
    #   When the Experience Composer ends, its stream is unpublished and an event is posted to the callback URL, if configured in the Account Portal.
    #
    # @option options [String] :resolution The resolution of the Experience Composer, either "640x480" (SD landscape), "480x640" (SD portrait), "1280x720" (HD landscape),
    #  "720x1280" (HD portrait), "1920x1080" (FHD landscape), or "1080x1920" (FHD portrait). By default, this resolution is "1280x720" (HD landscape, the default).
    #
    # @option options [Hash] :properties (Optional) The initial configuration of Publisher properties for the composed output stream. The properties object contains
    #  the key <code>:name</code> (String) which serves as the name of the composed output stream which is published to the session. The name must have a minimum length of 1 and 
    #  a maximum length of 200.
    #
    # @return [Render] The render object, which includes properties defining the render, including the render ID.
    #
    # @raise [OpenTokRenderError] The render could not be started. The request was invalid.
    # @raise [OpenTokAuthenticationError] Authentication failed while starting a render. Invalid API key.
    # @raise [OpenTokError] OpenTok server error.
    def start(session_id, options = {})
      raise ArgumentError, "session_id not provided" if session_id.to_s.empty?
      raise ArgumentError, "options cannot be empty" if options.empty?
      raise ArgumentError, "token property is required in options" unless options.has_key?(:token)
      raise ArgumentError, "url property is required in options" unless options.has_key?(:url)

      render_json = @client.start_render(session_id, options)
      Render.new self, render_json
    end

    # Stops an OpenTok Experience Composer render
    #
    # @param [String] render_id (Required) The render ID.
    #
    # @return [Render] The render object, which includes properties defining the render.
    #
    # @raise [OpenTokRenderError] The request was invalid.
    # @raise [OpenTokAuthenticationError] Authentication failed while stopping a render. Invalid API key.
    # @raise [OpenTokRenderError] No matching render found (with the specified ID) or it is already stopped
    # @raise [OpenTokError] OpenTok server error.
    def stop(render_id)
      raise ArgumentError, "render_id not provided" if render_id.to_s.empty?

      render_json = @client.stop_render(render_id)
      Render.new self, render_json
    end

    # Gets a Render object for the given render ID.
    #
    # @param [String] render_id (Required) The render ID.
    #
    # @return [Render] The render object, which includes properties defining the render.
    #
    # @raise [OpenTokRenderError] The request was invalid.
    # @raise [OpenTokAuthenticationError] Authentication failed while stopping a render. Invalid API key.
    # @raise [OpenTokRenderError] No matching render found (with the specified ID) or it is already stopped
    # @raise [OpenTokError] OpenTok server error.
    def find(render_id)
      raise ArgumentError, "render_id not provided" if render_id.to_s.empty?

      render_json = @client.get_render(render_id.to_s)
      Render.new self, render_json
    end

    # Returns a RenderList, which is an array of Experience Composers renders that are associated with a project.
    #
    # @param [Hash] options  A hash with keys defining which range of renders to retrieve.
    # @option options [integer] :offset (Optional). The start offset for the list of Experience Composer renders. The default is 0.
    # @option options [integer] :count Optional. The number of Experience Composer renders to retrieve starting at the offset. The default value
    #  is 50 and the maximum is 1000.
    #
    # @return [RenderList] An RenderList object, which is an array of Render objects.
    def list(options = {})
      raise ArgumentError, "Limit is invalid" unless options[:count].nil? || (0..1000).include?(options[:count])

      render_list_json = @client.list_renders(options[:offset], options[:count])
      RenderList.new self, render_list_json
    end
  end
end
