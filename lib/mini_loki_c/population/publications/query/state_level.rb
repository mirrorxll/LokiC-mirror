# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      module Query
        # Queries for getting MM publications
        module StateLevel
          module_function

          def pubs_query
            %|select o.name org_name,
                     c.id,
                     c.name,
                     cc.id client_id,
                     cc.name client_name
              from organizations o
                  join organization_communities oc
                      on oc.organization_id = o.id
                  join communities c
                      on c.id = oc.community_id
                  join client_companies cc
                      on c.client_company_id = cc.id
              where #{@client_ids.empty? ? '1 = 1' : "cc.id in (#{@client_ids})"} and
                    (c.id in (
                      select pg.project_id
                      from project_geographies pg
                          join communities c
                              on c.id = pg.project_id and
                                 pg.geography_type = 'State'
                          join client_companies cc on
                              cc.id = c.client_company_id and
                              cc.name rlike 'MM - ') or
                    c.id in (2041, 2419, 2394, 1541)) and
                    organization_id = #{@org_id}
              group by c.id;|
          end

          def all_state_lvl_pubs_query
            %|select c.id,
                     c.name,
                     cc.id client_id,
                     cc.name client_name
              from client_companies cc
                       join communities c
                            on cc.id = c.client_company_id
              where c.id in (
                  select pg.project_id
                  from project_geographies pg
                           join communities c
                                on c.id = pg.project_id and
                                   pg.geography_type = 'State'
                           join client_companies cc on
                              cc.id = c.client_company_id and
                              cc.name rlike 'MM - ') or
                      c.id in (2041, 2419, 2394, 1541)
              group by c.id;|
          end
        end
      end
    end
  end
end
