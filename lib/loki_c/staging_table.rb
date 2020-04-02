# frozen_string_literal: true

require 'loki_c/staging_table/columns'
require 'loki_c/staging_table/indices'

module LokiC
  class StagingTable # :nodoc:
    extend Columns
    extend Indices

    ARM = ActiveRecord::Migration

    def self.columns(t_name)
      columns = ARM.columns(t_name)
      columns_transform(columns, :back)
    end

    def self.index(t_name)
      indexes = ARM.indexes(t_name)
      index_columns = indexes.find { |i| i.name.eql?('story_per_publication') }
      index_transform(index_columns)
    end

    def self.modify_columns(t_name, cur_col, mod_col)
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
        ARM.rename_column(t_name, upd[:old_name], upd[:new_name])
        ARM.change_column(t_name, upd[:new_name], upd[:type], upd[:opts])
      end
    end

    def self.add_index(t_name, columns)
      columns = columns.map { |_id, c| c[:name] }
      columns = ['client_id', 'publication_id', columns].flatten
      ARM.add_index(t_name, columns, unique: true, name: :story_per_publication)
    end
  end
end
