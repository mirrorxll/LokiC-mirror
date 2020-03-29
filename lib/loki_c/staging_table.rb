# frozen_string_literal: true

require 'loki_c/staging_table/queries'
require 'loki_c/staging_table/columns'
require 'loki_c/staging_table/indices'

module LokiC
  module StagingTable # :nodoc:

    def self.columns(t_name)
      query = Queries.table_columns(t_name)
      columns = ActiveRecord::Base.connection.execute(query).to_a
      Columns.backend_transform(columns)
    end

    def self.index(t_name)
      query = Queries.table_index(t_name)
      index = ActiveRecord::Base.connection.exec_query(query).to_a
      Indices.transform(index)
    end

    def self.modify_columns(t_name, cur_col, mod_col)
      Columns.dropped(cur_col, mod_col).each do |hex|
        col = cur_col.delete(hex)
        ActiveRecord::Migration.remove_column(t_name, col[:name])
      end

      Columns.added(cur_col, mod_col).each do |hex|
        col = mod_col.delete(hex)
        ActiveRecord::Migration.add_column(t_name, col[:name], col[:type], col[:opts])
      end

      Columns.changed(cur_col, mod_col).each do |upd|
        ActiveRecord::Migration.rename_column(t_name, upd[:old_name], upd[:new_name])
        ActiveRecord::Migration.change_column(t_name, upd[:new_name], upd[:type], upd[:opts])
      end
    end
  end
end
