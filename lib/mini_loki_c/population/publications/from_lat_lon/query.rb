# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      class FromLatLon < Publications::Base
        private

        def pub_ids_by_shapes_query
          queries = @shapes.map do |shape|
            id = shape['id']
            type = shape['type']

            'SELECT pg.project_id id FROM project_geographies pg '\
            "JOIN #{type.pluralize} #{type} ON pg.geography_id = #{type}.id AND "\
            "pg.geography_type = '#{type.camelize}' WHERE #{type}.shape_id = #{id}"
          end

          "#{queries.join(' UNION DISTINCT ')};"
        end

        def pubs_query(pub_ids)
          clients = @clients.each_with_object([]) do |client, cl|
            cl << case client
                  when 'MM'
                    "cc.name like 'MM - %'"
                  when 'MB'
                    "cc.name = 'Metro Business Network'"
                  else
                    "cc.name = '#{client}'"
                  end
          end

          where = clients.any? ? "WHERE #{clients.join(' OR ')}" : ''

          %(SELECT c.id id,
                   c.name name,
                   cc.id client_id,
                   cc.name client_name
            FROM client_companies cc
              JOIN communities c
                ON c.client_company_id = cc.id
            WHERE c.client_company_id IN (
                    SELECT id
                    FROM client_companies
                    #{where}) AND
                  c.id IN (#{pub_ids.join(',')}) AND
                  c.id NOT IN (
                    SELECT pg.project_id
                    FROM project_geographies pg
                      JOIN communities c
                        ON c.id = pg.project_id AND
                           pg.geography_type = 'State'
                      JOIN client_companies cc on cc.id = c.client_company_id AND
                           cc.name rlike 'MM - ') AND
                  c.id NOT IN (2041, 2419, 2394)
            ORDER BY c.name;)
        end
      end
    end
  end
end
