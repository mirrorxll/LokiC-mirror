# frozen_string_literal: true

require_relative 'table/columns'
require_relative 'table/index'
require_relative 'table/query'

module Table # :nodoc:
  module_function

  extend Columns
  extend Index
  extend Query

  def a_r_m
    ActiveRecord::Migration
  end

  def connection
    ActiveRecord::Base.connection
  end

  def columns(t_name)
    columns = a_r_m.columns(t_name)
    columns_transform(columns, :back)
  end

  def index(t_name)
    indexes = a_r_m.indexes(t_name)
    index_columns = indexes.find { |i| i.name.eql?('story_per_publication') }
    index_transform(index_columns)
  end

  def modify_columns(t_name, cur_col, mod_col)
    if a_r_m.index_name_exists?(t_name, :story_per_publication)
      a_r_m.remove_index(t_name, name: :story_per_publication)
    end

    dropped(cur_col, mod_col).each do |hex|
      col = cur_col.delete(hex)
      a_r_m.remove_column(t_name, col[:name])
    end

    added(cur_col, mod_col).each do |hex|
      col = mod_col.delete(hex)
      a_r_m.add_column(t_name, col[:name], col[:type], col[:opts])
    end

    changed(cur_col, mod_col).each do |upd|
      if upd[:old_name] != upd[:new_name]
        a_r_m.rename_column(t_name, upd[:old_name], upd[:new_name])
      end

      a_r_m.change_column(t_name, upd[:new_name], upd[:type], upd[:opts])
    end
  end

  def add_index(t_name, columns)
    columns = columns.map { |_id, c| c[:name] }
    columns = ['client_id', 'publication_id', columns].flatten
    a_r_m.add_index(t_name, columns, unique: true, name: :story_per_publication)
  end

  def publication_ids(t_name)
    p_ids_query = publication_ids_query(t_name)
    p_ids = connection.exec_query(p_ids_query).to_a
    p_ids.map { |row| row['p_id'] }.compact
  end

  def last_iter_id(t_name)
    last_iter_query = iter_id_value_query(t_name)
    last_iter_id = connection.exec_query(last_iter_query).first['Column_Default']
    last_iter_id || 1
  end

  # purge rows that were inserted to staging table
  def purge_last_iteration(t_name)
    last_iter = last_iter_id(t_name)
    del_query = delete_query(t_name, last_iter)
    connection.exec_query(del_query)
  end

  # select edge staging table rows by columns
  def select_edge_ids(t_name, column_names)
    last_iter = last_iter_id(t_name)
    column_names.each_with_object([]) do |col_name, selected|
      min_query = select_minmax_id_query(t_name, last_iter, col_name, :MIN)
      max_query = select_minmax_id_query(t_name, last_iter, col_name, :MAX)

      selected << connection.exec_query(min_query).first['id']
      selected << connection.exec_query(max_query).first['id']
    end
  end

  def rows_by_ids(t_name, ids)
    last_iter = last_iter_id(t_name)
    rows_query = rows_by_ids_query(t_name, last_iter, ids)
    connection.exec_query(rows_query).to_a
  end

  def rows_by_last_iteration(t_name, options)
    last_iter = last_iter_id(t_name)
    rows_query = rows_by_last_iteration_query(t_name, last_iter, options)
    connection.exec_query(rows_query).to_a
  end

  def sample_set_as_created(t_name, id)
    upd_query = sample_created_update_query(t_name, id)
    connection.exec_query(upd_query)
  end

  def samples_set_as_not_created(t_name)
    last_iter = last_iter_id(t_name)
    upd_query = sample_destroyed_update_query(t_name, last_iter)
    connection.exec_query(upd_query)
  end

  def increment_iter_id(t_name)
    iter_id = last_iter_id(t_name)
    alter_query = alter_increment_iter_id_query(t_name, iter_id)
    connection.exec_query(alter_query)
  end
end
