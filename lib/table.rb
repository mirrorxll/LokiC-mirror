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

  def clients_publications(t_name, limit = nil)
    cl_pbs = connection.exec_query(clients_pubs_query(t_name, limit)).to_a

    cl_pbs.map do |row|
      { client_id: row.first, publication_ids: row.last.split(',') }
    end
  end

  # purge rows that were inserted to staging table
  def purge_last_iteration(t_name, iteration_id)
    query = delete_query(t_name, iteration_id)
    connection.exex_query(query)
  end

  # select edge staging table rows by columns
  def select_edge_ids(t_name, iteration_id, column_names)
    column_names.each_with_object([]) do |col_name, selected|
      min_query = select_minmax_id_query(t_name, iteration_id, col_name, :MIN)
      max_query = select_minmax_id_query(t_name, iteration_id, col_name, :MAX)

      selected << connection.exex_query(min_query).first['id']
      selected << connection.exex_query(max_query).first['id']
    end
  end
end
