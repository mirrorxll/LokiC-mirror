# frozen_string_literal: true


module LokiC
  module StagingTable # :nodoc:
    require_relative 'staging_table/queries.rb'
    require_relative 'staging_table/columns.rb'

    def self.exists?(t_name)
      ActiveRecord::Base.connection.table_exists?(t_name)
    end

    def self.create(t_name, columns)
      ActiveRecord::Migration.create_table(t_name, if_not_exists: true)
      ActiveRecord::Migration.add_column(t_name, :story_created, :boolean)
      ActiveRecord::Migration.add_column(t_name, :client_id, :integer)
      ActiveRecord::Migration.add_column(t_name, :client_name, :string)
      ActiveRecord::Migration.add_column(t_name, :project_id, :integer)
      ActiveRecord::Migration.add_column(t_name, :project_name, :string)
      ActiveRecord::Migration.add_column(t_name, :publish_on, :datetime)

      columns.each do |_id, col|
        ActiveRecord::Migration.add_column(t_name, col[:name], col[:type], col[:opts])
      end
    end

    def self.drop(name)
      ActiveRecord::Base.connection.drop_table(name)
    end

    def self.truncate(name)
      ActiveRecord::Base.connection.truncate(name)
    end

    def self.columns(t_name)
      query = Queries.column_list(t_name)
      columns = ActiveRecord::Base.connection.execute(query).to_a

      Columns.backend_transform(columns)
    rescue ActiveRecord::StatementInvalid => e
      { error: e }
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
