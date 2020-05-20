# frozen_string_literal: true

module Table
  # Custom queries for manipulated data
  # from staging tables
  module Query
    # return publication ids, grouped by a client id.
    def publication_ids_query(t_name)
      "SELECT GROUP_CONCAT(distinct publication_id) p_ids FROM `#{t_name}`;"
    end

    # update rows from staging table
    def sample_created_update_query(t_name, row_id)
      "UPDATE `#{t_name}` SET story_created = 1 WHERE id = #{row_id};"
    end

    # delete rows from staging table
    def delete_query(t_name, iteration_id)
      "DELETE FROM `#{t_name}` WHERE iteration_id = #{iteration_id}"
    end

    # return last iteration number from staging query
    def last_iteration_id_query(t_name)
      "SELECT MAX(iteration_id) iter_id FROM `#{t_name}`;"
    end

    # return staging table row id equal
    # min or max value by iteration_id
    def select_minmax_id_query(t_name, iteration_id, column_name, type)
      sub_query = "SELECT #{type}(`#{column_name}`) "\
                  "FROM `#{t_name}` WHERE iteration_id = #{iteration_id}"

      'SELECT id '\
      "FROM `#{t_name}` "\
      "WHERE iteration_id = #{iteration_id} AND "\
             "`#{column_name}` = (#{sub_query})"\
      'LIMIT 1;'
    end

    def rows_by_ids_query(t_name, iteration_id, options)
      "SELECT * FROM `#{t_name}` "\
      "WHERE story_created = 0 AND id IN (#{options[:ids]}) AND "\
      "iteration_id = #{iteration_id} "\
      "LIMIT #{options[:limit] || 7_000};"
    end

    def last_iteration_rows_query(t_name, iteration_id, options)
      "SELECT * FROM `#{t_name}` "\
      "WHERE story_created = 0 AND iteration_id = (#{iteration_id}) "\
      "LIMIT #{options[:limit] || 7_000};"
    end
  end
end
