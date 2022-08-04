# frozen_string_literal: true

module Table
  # Custom queries for manipulated data
  # from staging tables
  module Query
    def schema
      Rails.configuration.database_configuration[Rails.env]['loki_story_creator']['database']
    end

    def schema_table(t_name)
      curr_schema = schema
      data_location = "#{schema}.#{t_name}"
      t_name.start_with?("#{curr_schema}.") ? t_name : data_location
    end

    def and_publication_ids(ids)
      ids.empty? ? '' : "AND publication_id IN (#{ids.join(',')})"
    end

    # return number of rows for passed iteration
    def count_rows_by_iter_query(t_name, iter_id)
      "SELECT COUNT(*) count FROM #{schema_table(t_name)} WHERE iter_id = #{iter_id};"
    end

    # return publication ids, grouped by a client id.
    def publication_ids_query(t_name, iter_id, publication_ids)
      "SELECT distinct publication_id p_id FROM #{schema_table(t_name)} "\
      "WHERE iter_id = #{iter_id} #{and_publication_ids(publication_ids)};"
    end

    # return default iteration number from staging table
    def iter_id_value_query(t_name)
      'SELECT Column_Default default_value FROM Information_Schema.Columns '\
      "WHERE Table_Schema = '#{schema}' AND "\
            "Table_Name = '#{t_name}' AND Column_Name = 'iter_id';"
    end

    # mark staging table's row as sample/story as created
    def story_created_update_query(t_name, row_id)
      "UPDATE #{schema_table(t_name)} SET story_created = TRUE WHERE id = #{row_id};"
    end

    # mark staging table's row as sample/story as not created
    def story_not_created_update_query(t_name, row_id)
      "UPDATE #{schema_table(t_name)} SET story_created = FALSE WHERE id = #{row_id};"
    end

    # mark staging table's row as sample/article as created
    def article_created_update_query(t_name, row_id)
      "UPDATE #{schema_table(t_name)} SET article_created = TRUE WHERE id = #{row_id};"
    end

    # mark staging table's row as sample/article as not created
    def article_not_created_update_query(t_name, row_id)
      "UPDATE #{schema_table(t_name)} SET article_created = FALSE WHERE id = #{row_id};"
    end

    # delete rows from staging table
    def delete_query(t_name, iter_id)
      "DELETE FROM #{schema_table(t_name)} WHERE iter_id = #{iter_id}"
    end

    # return staging table row id equal
    # min or max value by iteration_id
    def select_minmax_id_query(t_name, iter_id, column_name, type, *publication_ids)
      sub_query = "SELECT #{type}(`#{column_name}`) "\
                  "FROM #{schema_table(t_name)} WHERE iter_id = #{iter_id} #{and_publication_ids(publication_ids)}"

      'SELECT id '\
      "FROM #{schema_table(t_name)} "\
      "WHERE iter_id = #{iter_id} AND "\
      "`#{column_name}` = (#{sub_query}) #{and_publication_ids(publication_ids)} "\
      'LIMIT 1;'
    end

    def rows_by_ids_query(t_name, iter_id, options)
      pub_ids = options[:publication_ids] || []

      "SELECT * FROM #{schema_table(t_name)} "\
      "WHERE (#{options[:type]}_created = 0 OR #{options[:type]}_created IS NULL) "\
      "#{and_publication_ids(pub_ids)} AND id IN (#{options[:ids]}) AND iter_id = #{iter_id};"
    end

    def rows_by_iteration_query(t_name, iter_id, options)
      pub_ids = options[:publication_ids] || []

      "SELECT * FROM #{schema_table(t_name)} "\
      "WHERE (#{options[:type]}_created = 0 OR #{options[:type]}_created IS NULL) AND "\
      "iter_id = (#{iter_id}) #{and_publication_ids(pub_ids)} "\
      "LIMIT #{options[:limit] || 10_000};"
    end

    def all_stories_created_by_iteration_query(t_name, iter_id, publication_ids)
      "SELECT id FROM #{schema_table(t_name)} "\
      'WHERE (story_created = 0 OR story_created IS NULL) AND '\
      "iter_id = (#{iter_id}) #{and_publication_ids(publication_ids)} "\
      'LIMIT 1;'
    end

    def all_articles_created_by_iteration_query(t_name, iter_id)
      "SELECT id FROM #{schema_table(t_name)} "\
      'WHERE (article_created = 0 OR article_created IS NULL) AND '\
      "iter_id = (#{iter_id}) "\
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

    # returns staging table columns 'limpar_year' and 'limpar_id'
    def limpar_year(t_name, iter_id)
      'SELECT id, limpar_year, limpar_id ' \
      "FROM #{schema_table(t_name)} " \
      "WHERE iter_id = #{iter_id};"
    end

    # delete rows in staging table
    def delete_st_table_rows(t_name, iter_id, row_ids)
      rows = row_ids.join(', ')

      "DELETE FROM #{schema_table(t_name)} WHERE iter_id = #{iter_id} AND id IN (#{rows});"
    end
  end
end
