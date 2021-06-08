# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      module Query
        # Queries for getting MM publications
        module MetricMedia
          module_function

          def ids_states_query
            %|select id client_id,
                     replace(name, 'MM - ', '') state
              from client_companies
              where name like 'MM -%';|
          end

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
              where cc.id in (#{@client_ids}) and
                    c.id not in (
                      select pg.project_id
                      from project_geographies pg
                          join communities c
                              on c.id = pg.project_id
                          join client_companies cc on
                              cc.id = c.client_company_id
                      where pg.geography_type = 'State' and
                            cc.name rlike 'MM - '
                    ) and
                    c.id not in (2041, 2419, 2394) and
                    organization_id = #{@org_id}
              group by c.id;|
          end

          def pubs_by_passed_states_query
            %|select c.id as id,
                     c.name as name,
                     cc.id as client_id,
                     cc.name as client_name
              from client_companies as cc
                  join communities as c
                      on c.client_company_id = cc.id
              where cc.id in (#{@client_ids}) and
                    c.id not in (
                      select pg.project_id
                      from project_geographies pg
                          join communities c
                              on c.id = pg.project_id
                          join client_companies cc
                              on cc.id = c.client_company_id
                      where pg.geography_type = 'State' and
                            cc.id in (#{@client_ids})
                    ) and
                    c.id not in (2041, 2419, 2394);|
          end
        end
      end
    end
  end
end
