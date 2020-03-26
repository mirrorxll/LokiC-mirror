# frozen_string_literal: true


module LokiC
  module StagingTable # :nodoc:
    require_relative 'staging_table/queries.rb'
    require_relative 'staging_table/columns.rb'
    require_relative 'staging_table/indices.rb'

    def self.columns(t_name)
      query = Queries.table_columns(t_name)
      columns = ActiveRecord::Base.connection.execute(query).to_a
      Columns.backend_transform(columns)
    end

    def self.indices(t_name)
      query = Queries.table_indices(t_name)
      indices = ActiveRecord::Base.connection.exec_query(query).to_a
      Indices.transform(indices)
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
