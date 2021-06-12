# frozen_string_literal: true

module Table
  # Custom queries for manipulated data
  # from staging tables
  module Query
    def schema
      case Rails.env
      when 'production'
        'loki_storycreator'
      when 'development'
        'loki_story_creator_dev'
      when 'test'
        'loki_story_creator_test'
      end
    end

    def schema_table(t_name)
      curr_schema = schema
      data_location = "#{schema}.#{t_name}"
      t_name.start_with?("#{curr_schema}.") ? t_name : data_location
    end

    def and_client_ids(ids)
      ids.empty? ? '' : "AND client_id IN (#{ids})"
    end

    # return publication ids, grouped by a client id.
    def publication_ids_query(t_name, iter_id, client_ids)
      "SELECT distinct publication_id p_id FROM #{schema_table(t_name)} "\
      "WHERE iter_id = #{iter_id} #{and_client_ids(client_ids)};"
    end

    # return default iteration number from staging table
    def iter_id_value_query(t_name)
      'SELECT Column_Default default_value FROM Information_Schema.Columns '\
      "WHERE Table_Schema = '#{schema}' AND "\
            "Table_Name = '#{t_name}' AND Column_Name = 'iter_id';"
    end

    # mark staging table's row as sample/story as created
    def sample_created_update_query(t_name, row_id)
      "UPDATE #{schema_table(t_name)} SET story_created = TRUE WHERE id = #{row_id};"
    end

    # mark staging table's row as sample/story as not created
    def sample_not_created_update_query(t_name, row_id)
      "UPDATE #{schema_table(t_name)} SET story_created = FALSE WHERE id = #{row_id};"
    end

    # delete rows from staging table
    def delete_query(t_name, iter_id)
      "DELETE FROM #{schema_table(t_name)} WHERE iter_id = #{iter_id}"
    end

    # return staging table row id equal
    # min or max value by iteration_id
    def select_minmax_id_query(t_name, iter_id, client_ids, column_name, type)
      sub_query = "SELECT #{type}(`#{column_name}`) "\
                  "FROM #{schema_table(t_name)} WHERE iter_id = #{iter_id} #{and_client_ids(client_ids)}"

      'SELECT id '\
      "FROM #{schema_table(t_name)} "\
      "WHERE iter_id = #{iter_id} AND "\
      "`#{column_name}` = (#{sub_query}) #{and_client_ids(client_ids)} "\
      'LIMIT 1;'
    end

    def rows_by_ids_query(t_name, iter_id, options)
      "SELECT * FROM #{schema_table(t_name)} "\
      "WHERE (story_created = 0 OR story_created IS NULL) #{and_client_ids(options[:client_ids])} AND "\
      "id IN (#{options[:ids]}) AND iter_id = #{iter_id};"
    end

    def rows_by_last_iteration_query(t_name, iter_id, options)
      "SELECT * FROM #{schema_table(t_name)} "\
      'WHERE (story_created = 0 OR story_created IS NULL) AND '\
      "iter_id = (#{iter_id}) #{and_client_ids(options[:client_ids])} "\
      "LIMIT #{options[:limit] || 10_000};"
    end

    def all_created_by_last_iteration_query(t_name, iter_id, raw_client_ids)
      "SELECT id FROM #{schema_table(t_name)} "\
      'WHERE (story_created = 0 OR story_created IS NULL) AND '\
      "iter_id = (#{iter_id}) #{and_client_ids(raw_client_ids)} "\
      'LIMIT 1;'
    end

    def created_at_default_value_query(t_name)
      "ALTER TABLE #{t_name} CHANGE COLUMN created_at created_at "\
      'TIMESTAMP DEFAULT CURRENT_TIMESTAMP;'
    end

    def updated_at_default_value_query(t_name)
      "ALTER TABLE #{t_name} CHANGE COLUMN updated_at updated_at "\
      'TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;'
    end

    def alter_change_iter_id_query(t_name, iter_id)
      "ALTER TABLE #{t_name} "\
      "MODIFY COLUMN iter_id int NOT NULL DEFAULT #{iter_id};"
    end
  end
end
