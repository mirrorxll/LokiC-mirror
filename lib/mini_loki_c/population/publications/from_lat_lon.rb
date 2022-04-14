# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      # get publications by lat/lon
      class FromLatLon < Publications::Base
        include Query::FromLatLon

        TYPES = %w[
          city
          state
          county
          project_zone
          township
          country
          postal_code
          unified_school
          neighborhood
          elementary_school
        ].freeze

        def initialize(latitude, longitude, clients = [])
          super()
          @coord = { lat: latitude, lon: longitude }
          @clients = clients
          @shapes = []
        end

        def pubs
          pub_ids = publication_ids
          return [] if pub_ids.empty?

          get(pubs_query(pub_ids))
        end

        private

        def publication_ids
          response = Pipeline[:shapes].get_shapes(@coord)
          return [] if (response.status / 100) != 2

          @shapes = JSON.parse(response.body).keep_if { |s| TYPES.include?(s['type']) }
          return [] if @shapes.empty?

          @route.query(pub_ids_by_shapes_query).to_a.map { |pub| pub['id'] }
        end
      end
    end
  end
end
