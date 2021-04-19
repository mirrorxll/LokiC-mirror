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
    ActiveRecord::Base.connected_to(database: { slow: :loki_story_creator }) { yield }
  end

  def a_r_m
    ActiveRecord::Migration
  end

  def a_r_b_conn
    ActiveRecord::Base.connection
  end

  def exists?(t_name)
    loki_story_creator { a_r_m.table_exists?(t_name) }
  end

  def last_iter_id(t_name)
    last_iter_query = iter_id_value_query(t_name)
    loki_story_creator { a_r_b_conn.exec_query(last_iter_query).first['default_value'] }
  end

  def publication_ids(t_name, client_ids)
    last_iter_id = last_iter_id(t_name)
    p_ids_query = publication_ids_query(t_name, last_iter_id, client_ids)
    p_ids = loki_story_creator { a_r_b_conn.exec_query(p_ids_query).to_a }
    p_ids.map { |row| row['p_id'] }.compact
  end

  # purge rows that were inserted to staging table
  def purge_last_iteration(t_name)
    last_iter = last_iter_id(t_name)
    del_query = delete_query(t_name, last_iter)
    loki_story_creator { a_r_b_conn.exec_query(del_query) }

    nil
  end

  # select edge staging table rows by columns
  def select_edge_ids(t_name, client_ids, column_names)
    last_iter = last_iter_id(t_name)
    column_names.each_with_object([]) do |col_name, selected|
      min_query = select_minmax_id_query(t_name, last_iter, client_ids, col_name, :MIN)
      max_query = select_minmax_id_query(t_name, last_iter, client_ids, col_name, :MAX)

      loki_story_creator do
        min = a_r_b_conn.exec_query(min_query).first
        selected << min['id'] if min
        max = a_r_b_conn.exec_query(max_query).first
        selected << max['id'] if max
      end
    end
  end

  def rows_by_ids(t_name, options)
    last_iter = last_iter_id(t_name)
    rows_query = rows_by_ids_query(t_name, last_iter, options)
    loki_story_creator { a_r_b_conn.exec_query(rows_query).to_a }
  end

  def rows_by_last_iteration(t_name, options)
    last_iter = last_iter_id(t_name)
    rows_query = rows_by_last_iteration_query(t_name, last_iter, options)
    loki_story_creator { a_r_b_conn.exec_query(rows_query).to_a }
  end

  def all_created_by_last_iteration?(t_name, client_ids)
    last_iter = last_iter_id(t_name)
    rows_query = all_created_by_last_iteration_query(t_name, last_iter, client_ids)
    loki_story_creator { a_r_b_conn.exec_query(rows_query).first.nil? }
  end

  def sample_set_as_created(t_name, id)
    upd_query = sample_created_update_query(t_name, id)
    loki_story_creator { a_r_b_conn.exec_query(upd_query) }

    nil
  end

  def sample_set_as_not_created(t_name, id)
    upd_query = sample_not_created_update_query(t_name, id)
    loki_story_creator { a_r_b_conn.exec_query(upd_query) }

    nil
  end

  def change_iter_id(t_name, iter_id)
    alter_query = alter_change_iter_id_query(t_name, iter_id)
    loki_story_creator { a_r_b_conn.exec_query(alter_query) }

    nil
  end
end
