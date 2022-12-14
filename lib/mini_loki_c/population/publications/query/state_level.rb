# frozen_string_literal: true

module MiniLokiC
  module Population
    module Publications
      module Query
        # Queries for getting MM publications
        module StateLevel
          module_function

          def clients_ids_states_query
            %|select cc.id client_id,
                     if(
                         substr(cc.name, 1, 4) = 'MM -',
                         replace(cc.name, 'MM - ', ''),
                         if(cc.name = 'LGIS', 'Illinois', null)
                     ) state
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

          def pubs_query
            %|select c.id,
                     c.name,
                     cc.id client_id,
                     cc.name client_name
              from client_companies cc
                  join communities c
                      on cc.id = c.client_company_id
              where #{@client_ids&.present? ? "cc.id in (#{@client_ids})" : '1 = 1'} and
                    (c.id in (
                      select pg.project_id
                      from project_geographies pg
                          join communities c
                              on c.id = pg.project_id and
                                 pg.geography_type = 'State'
                          join client_companies cc on
                              cc.id = c.client_company_id and
                              cc.name rlike 'MM - ') or
                    c.id in (2041, 2419, 2394, 1541))
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
