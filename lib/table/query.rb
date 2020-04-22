# frozen_string_literal: true

module Table
  # Custom queries for manipulated data
  # from staging tables
  module Query
    # Query returns publication ids, grouped by a client id. Also, it is excluding
    # publications for which a configuration export has already been created.
    def clients_pubs_query(t_name, limit = nil)
      'SELECT stg.client_id, GROUP_CONCAT(distinct stg.publication_id) publication_ids '\
      "FROM `#{t_name}` stg "\
        'LEFT JOIN export_configurations expc ON '\
          'expc.story_type_id = 1 AND '\
          'expc.client_id = stg.client_id AND '\
          'expc.publication_id = stg.publication_id '\
      'WHERE stg.client_id is not null AND '\
            'expc.publication_id IS NULL '\
      'GROUP BY client_id '\
      "#{limit ? "LIMIT #{limit}" : ''};"
    end
  end
end
