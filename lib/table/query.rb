# frozen_string_literal: true

module Table
  # Custom queries for manipulated data
  # from staging tables
  module Query
    # return publication ids, grouped by a client id.
    def publication_ids_query(t_name)
      "SELECT distinct publication_id p_id FROM `#{t_name}`;"
    end

    # update rows from staging table
    def sample_created_update_query(t_name, row_id)
      "UPDATE `#{t_name}` SET story_created = 1 WHERE id = #{row_id};"
    end

    # delete rows from staging table
    def delete_query(t_name, iter_id)
      "DELETE FROM `#{t_name}` WHERE iter_id = #{iter_id}"
    end

    # return last iteration number from staging query
    def last_iter_id_query(t_name)
      "SELECT MAX(iter_id) iter_id FROM `#{t_name}`;"
    end

    # return staging table row id equal
    # min or max value by iteration_id
    def select_minmax_id_query(t_name, iter_id, column_name, type)
      sub_query = "SELECT #{type}(`#{column_name}`) "\
                  "FROM `#{t_name}` WHERE iter_id = #{iter_id}"

      'SELECT id '\
      "FROM `#{t_name}` "\
      "WHERE iter_id = #{iter_id} AND "\
             "`#{column_name}` = (#{sub_query})"\
      'LIMIT 1;'
    end

    def rows_by_ids_query(t_name, iter_id, options)
      "SELECT * FROM `#{t_name}` "\
      "WHERE story_created = 0 AND id IN (#{options[:ids]}) AND "\
      "iter_id = #{iter_id} "\
      "LIMIT #{options[:limit] || 7_000};"
    end

    def rows_by_last_iteration_query(t_name, iter_id, options)
      "SELECT * FROM `#{t_name}` "\
      "WHERE story_created = 0 AND iter_id = (#{iter_id}) "\
      "LIMIT #{options[:limit] || 7_000};"
    end
  end
end
