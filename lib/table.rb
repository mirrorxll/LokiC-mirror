# frozen_string_literal: true

require_relative 'table/columns'
require_relative 'table/index'
require_relative 'table/query'

module Table # :nodoc:
  module_function

  extend Columns
  extend Index
  extend Query

  ARM = ActiveRecord::Migration
  ARB_CONN = ActiveRecord::Base.connection

  def columns(t_name)
    columns = ARM.columns(t_name)
    columns_transform(columns, :back)
  end

  def index(t_name)
    indexes = ARM.indexes(t_name)
    index_columns = indexes.find { |i| i.name.eql?('story_per_publication') }
    index_transform(index_columns)
  end

  def modify_columns(t_name, cur_col, mod_col)
    if ARM.index_name_exists?(t_name, :story_per_publication)
      ARM.remove_index(t_name, name: :story_per_publication)
    end

    dropped(cur_col, mod_col).each do |hex|
      col = cur_col.delete(hex)
      ARM.remove_column(t_name, col[:name])
    end

    added(cur_col, mod_col).each do |hex|
      col = mod_col.delete(hex)
      ARM.add_column(t_name, col[:name], col[:type], col[:opts])
    end

    changed(cur_col, mod_col).each do |upd|
      if upd[:old_name] != upd[:new_name]
        ARM.rename_column(t_name, upd[:old_name], upd[:new_name])
      end

      ARM.change_column(t_name, upd[:new_name], upd[:type], upd[:opts])
    end
  end

  def add_index(t_name, columns)
    columns = columns.map { |_id, c| c[:name] }
    columns = ['client_id', 'publication_id', columns].flatten

    ARM.add_index(t_name, columns, unique: true, name: :story_per_publication)
  end

  def clients_publications(t_name, limit = nil)
    cl_pbs = ARB_CONN.execute(clients_pubs_query(t_name, limit)).to_a

    cl_pbs.map do |row|
      { client_id: row.first, publication_ids: row.last.split(',') }
    end
  end

  # purge rows that were insertedto staging table
  def purge_last_iteration(t_name, iteration_id)
    where = "iteration_id = #{iteration_id}"
    ARB_CONN.execute(delete_query(t_name, where))
  end
end
