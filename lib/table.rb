# frozen_string_literal: true

require_relative 'table/columns.rb'
require_relative 'table/index.rb'
require_relative 'table/query.rb'
require_relative 'table/create.rb'

module Table # :nodoc:
  module_function

  extend Columns
  extend Index
  extend Query
  extend Create

  def loki_story_creator
    yield(ActiveRecord::Base.connection)
  end

  def exists?(t_name)
    t_name = schema_table(t_name)
    loki_story_creator { |conn| conn.table_exists?(t_name) }
  end

  def curr_iter_id(t_name)
    curr_iter_query = iter_id_value_query(t_name)
    loki_story_creator { |conn| conn.exec_query(curr_iter_query).first['default_value'] }
  end

  def publication_ids(t_name, publication_ids)
    curr_iter_id = curr_iter_id(t_name)
    p_ids_query = publication_ids_query(t_name, curr_iter_id, publication_ids)
    p_ids = loki_story_creator { |conn| conn.exec_query(p_ids_query).to_a }
    p_ids.map { |row| row['p_id'] }.compact
  end

  # return true if number of rows for passed iteration is zero, opposite - false
  def rows_absent?(t_name, iteration_id)
    count_query = count_rows_by_iter_query(t_name, iteration_id)
    loki_story_creator { |conn| conn.exec_query(count_query).first['count'].zero? }
  end

  # purge rows that were inserted to staging table
  def purge_last_iteration(t_name)
    curr_iter = curr_iter_id(t_name)
    del_query = delete_query(t_name, curr_iter)
    loki_story_creator { |conn| conn.exec_query(del_query) }

    nil
  end

  # select edge staging table rows by columns
  def select_edge_ids(t_name, column_names, *publication_ids)
    curr_iter = curr_iter_id(t_name)

    column_names.each_with_object([]) do |col_name, selected|
      min_query = select_minmax_id_query(t_name, curr_iter, col_name, :MIN, *publication_ids)
      max_query = select_minmax_id_query(t_name, curr_iter, col_name, :MAX, *publication_ids)

      loki_story_creator do |conn|
        min = conn.exec_query(min_query).first
        selected << min['id'] if min
        max = conn.exec_query(max_query).first
        selected << max['id'] if max
      end
    end
  end

  def rows_by_ids(t_name, options)
    curr_iter = curr_iter_id(t_name)
    rows_query = rows_by_ids_query(t_name, curr_iter, options)
    loki_story_creator { |conn| conn.exec_query(rows_query).to_a }
  end

  def rows_by_iteration(t_name, options)
    curr_iter = curr_iter_id(t_name)
    rows_query = rows_by_iteration_query(t_name, curr_iter, options)
    loki_story_creator { |conn| conn.exec_query(rows_query).to_a }
  end

  def all_stories_created_by_iteration?(t_name, publication_ids)
    curr_iter = curr_iter_id(t_name)
    rows_query = all_stories_created_by_iteration_query(t_name, curr_iter, publication_ids)
    loki_story_creator { |conn| conn.exec_query(rows_query).first.nil? }
  end

  def all_articles_created_by_iteration?(t_name)
    curr_iter = curr_iter_id(t_name)
    rows_query = all_articles_created_by_iteration_query(t_name, curr_iter)
    loki_story_creator { |conn| conn.exec_query(rows_query).first.nil? }
  end

  def story_set_as_created(t_name, id)
    upd_query = story_created_update_query(t_name, id)
    loki_story_creator { |conn| conn.exec_query(upd_query) }

    nil
  end

  def story_set_as_not_created(t_name, id)
    upd_query = story_not_created_update_query(t_name, id)
    loki_story_creator { |conn| conn.exec_query(upd_query) }

    nil
  end

  def article_set_as_created(t_name, id)
    upd_query = article_created_update_query(t_name, id)
    loki_story_creator { |conn| conn.exec_query(upd_query) }

    nil
  end

  def article_set_as_not_created(t_name, id)
    upd_query = article_not_created_update_query(t_name, id)
    loki_story_creator { |conn| conn.exec_query(upd_query) }

    nil
  end

  def change_iter_id(t_name, iter_id)
    alter_query = alter_change_iter_id_query(t_name, iter_id)
    loki_story_creator { |conn| conn.exec_query(alter_query) }

    nil
  end
end
