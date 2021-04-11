# frozen_string_literal: true

module Table
  # Custom queries for manipulated data
  # from staging tables
  module Query
    # return publication ids, grouped by a client id.
    def publication_ids_query(t_name, iter_id)
      "SELECT distinct publication_id p_id FROM `#{t_name}` "\
      "WHERE iter_id = #{iter_id};"
    end

    # return default iteration number from staging table
    def iter_id_value_query(t_name)
      schema =
        case Rails.env
        when 'production'
          'loki_storycreator'
        when 'development'
          'loki_story_creator_dev'
        when 'test'
          'loki_story_creator_test'
        else
          raise StandardError, 'Wrong Rails ENV'
        end

      'SELECT Column_Default default_value FROM Information_Schema.Columns '\
      "WHERE Table_Schema = '#{schema}' AND "\
            "Table_Name = '#{t_name}' AND Column_Name = 'iter_id';"
    end

    # mark staging table's row as sample/story as created
    def sample_created_update_query(t_name, row_id)
      "UPDATE `#{t_name}` SET story_created = TRUE WHERE id = #{row_id};"
    end

    # mark staging table's row as sample/story as not created
    def sample_not_created_update_query(t_name, row_id)
      "UPDATE `#{t_name}` SET story_created = FALSE WHERE id = #{row_id};"
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
      'WHERE (story_created = 0 OR story_created IS NULL) AND '\
      "id IN (#{options[:ids]}) AND iter_id = #{iter_id};"
    end

    def rows_by_last_iteration_query(t_name, iter_id, options)
      "SELECT * FROM `#{t_name}` "\
      "WHERE (story_created = 0 OR story_created IS NULL) AND iter_id = (#{iter_id}) "\
      "LIMIT #{options[:limit] || 10_000};"
    end

    def all_created_by_last_iteration_query(t_name, iter_id)
      "SELECT id FROM `#{t_name}` "\
      "WHERE (story_created = 0 OR story_created IS NULL) AND iter_id = (#{iter_id})"\
      'LIMIT 1;'
    end

    def created_at_default_value_query(name)
      "ALTER TABLE `#{name}` CHANGE COLUMN created_at created_at "\
      'TIMESTAMP DEFAULT CURRENT_TIMESTAMP;'
    end

    def updated_at_default_value_query(name)
      "ALTER TABLE `#{name}` CHANGE COLUMN updated_at updated_at "\
      'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;'
    end

    def alter_change_iter_id_query(t_name, iter_id)
      "ALTER TABLE `#{t_name}` "\
      "MODIFY COLUMN iter_id int NOT NULL DEFAULT #{iter_id};"
    end
  end
end
