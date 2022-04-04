# frozen_string_literal: true

module Pipeline
  class ShapesClient < Base
    include ShapesEndpoint

    def initialize
      Pipeline.shapes_options.each { |name, value| send("#{name}=", value) }
    end
  end
end
