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

      columns.each do |c|
        ActiveRecord::Migration.add_column(t_name, c[:name], c[:type], c[:opts])
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
      Columns.transform_exist(columns)
    rescue ActiveRecord::StatementInvalid => e
      { error: e }
    end

    def self.columns_by_hex(t_name)
      cols = columns(t_name)
      Columns.transform_by_hex(cols)
    end

    def self.alter(t_name, cur_col, mod_col)
      q = ["ALTER TABLE `#{t_name}`"]
      Columns.dropped(cur_col, mod_col).each { |c| q << "DROP COLUMN `#{c['name']}`," }
      Columns.added(cur_col, mod_col).each { |c| q << "ADD COLUMN `#{c[:name]}` #{c[:type]}," }
      Columns.changed(cur_col, mod_col).each do |c|
        q << "CHANGE COLUMN `#{c[:old_name]}` `#{c[:new_name]}` #{c[:new_type]},"
      end

      q.count > 1 ? q.join(' ')[0..-2] + ';' : nil
    end
  end
end
