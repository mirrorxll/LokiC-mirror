# frozen_string_literal: true

module Pipeline
  module ShapesEndpoint
    # get shape from lat/lon
    module Shapes
      def get_shapes(params = {})
        get('contains_coordinate', params)
      end
    end
  end
end

