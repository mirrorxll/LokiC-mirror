# frozen_string_literal: true

require_relative 'shapes_endpoint.rb'

module Pipeline
  class ShapesClient < Base
    include ShapesEndpoint

    def initialize
      Pipeline.shapes_options.each { |name, value| send("#{name}=", value) }
    end
  end
end
