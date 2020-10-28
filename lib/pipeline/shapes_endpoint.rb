# frozen_string_literal: true

require_relative 'shapes_endpoint/shapes.rb'

module Pipeline
  # assembling main endpoints
  module ShapesEndpoint
    include Shapes
  end
end
