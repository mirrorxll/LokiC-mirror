# frozen_string_literal: true

module Table
  # Custom queries for manipulated data
  # from staging tables
  module Query
    # return publication ids, grouped by a client id.
    def clients_pubs_query(t_name)
      'SELECT stg.client_id, GROUP_CONCAT(distinct stg.publication_id) pub_ids '\
      "FROM `#{t_name}`;"
    end

    # delete rows from staging table
    def delete_query(t_name, iteration_id)
      "DELETE FROM `#{t_name}` WHERE iteration_id = #{iteration_id}"
    end

    # return staging table row id equal
    # min or max value by iteration_id
    def select_minmax_id_query(t_name, iteration_id, column_name, type)
      sub_query = "SELECT #{type}(`#{column_name}`) "\
                  "FROM `#{t_name}` WHERE iteration_id = #{iteration_id}"

      'SELECT id '\
      "FROM `#{t_name}` "\
      "WHERE iteration_id = #{iteration_id} AND"\
             "`#{column_name}` = (#{sub_query})"\
      'LIMIT 1;'
    end

    def select_query(t_name, options = {})
      max_iter_id = "select max(iteration_id) from `#{t_name}`"

      "SELECT * FROM `#{t_name}` WHERE id IN (#{options[:ids]}) AND "\
      "iteration_id = (#{max_iter_id}) LIMIT #{options[:limit] || 7_000};"
    end
  end
end
