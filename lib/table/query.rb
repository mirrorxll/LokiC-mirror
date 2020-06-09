# frozen_string_literal: true

module Table
  # Custom queries for manipulated data
  # from staging tables
  module Query
    # return publication ids, grouped by a client id.
    def publication_ids_query(t_name)
      "SELECT distinct publication_id p_id FROM `#{t_name}`;"
    end

    # return default iteration number from staging table
    def iter_id_value_query(t_name)
      schema =
        case Rails.env
        when 'production'
          'lokic'
        when 'development'
          'lokic_dev'
        when 'test'
          'lokic_test'
        else
          raise StandardError, 'Wrong Rails ENV'
        end

      'SELECT Column_Default FROM Information_Schema.Columns '\
      "WHERE Table_Schema = '#{schema}' AND "\
            "Table_Name = '#{t_name}' AND Column_Name = 'iter_id';"
    end

    # mark staging table's row as sample/story as created
    def sample_created_update_query(t_name, row_id)
      "UPDATE `#{t_name}` SET story_created = TRUE WHERE id = #{row_id};"
    end

    # mark staging table's row as sample/story as not creates
    def sample_destroyed_update_query(t_name, iter_id)
      "UPDATE `#{t_name}` SET story_created = FALSE "\
      "WHERE iter_id = #{iter_id};"
    end

    # delete rows from staging table
    def delete_query(t_name, iter_id)
      "DELETE FROM `#{t_name}` WHERE iter_id = #{iter_id}"
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

    def alter_increment_iter_id_query(t_name, value)
      "ALTER TABLE `#{t_name}` "\
      "MODIFY COLUMN iter_id int NOT NULL DEFAULT #{value + 1};"
    end
  end
end
