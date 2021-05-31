# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      module Query
        # Queries for getting publications by client id
        module ByClientsState
          module_function

          def lgis_query
            %(SELECT c.id id,
                     c.name name,
                     cc.id client_id,
                     cc.name client_name
              FROM organization_communities oc
                JOIN communities c
                  ON c.id = oc.community_id
                JOIN client_companies cc
                  ON cc.id = c.client_company_id
              WHERE c.client_company_id = 91 and
                    c.id != 1541
              GROUP BY c.id;)
          end

          def mb_query
            state =
              @state ? "JOIN states s ON pg.geography_id = s.id AND s.name = '#{@state}'" : ''

            %(SELECT c.id id,
                     c.name name,
                     cc.id client_id,
                     cc.name AS client_name
              FROM client_companies cc
                JOIN communities c
                  ON c.client_company_id = cc.id
                JOIN project_geographies pg
                  ON c.id = pg.project_id AND
                     pg.geography_type = 'State'
                #{state}
              WHERE c.client_company_id = 120
              ORDER BY c.name;)
          end

          def mm_query
            mm_clients = @state ? "name = 'MM - #{@state}'" : "name rlike 'MM - '"

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
                      WHERE #{mm_clients}) AND
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
end
