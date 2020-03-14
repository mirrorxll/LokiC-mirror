# frozen_string_literal: true


module LokiC
  module StagingTable # :nodoc:
    require_relative 'staging_table/queries.rb'
    require_relative 'staging_table/columns.rb'

    def self.attach(t_name)
      ActiveRecord::Base.connected_to(database: { slow: :hle }) do
        columns = ActiveRecord::Base.connection.execute(Queries.column_list(t_name))
        columns = Ids.transform(columns)

      end
    end

    def self.create(name, columns)
      ActiveRecord::Base.connected_to(database: { slow: :hle }) do
        ActiveRecord::Migration.create_table(name, if_not_exists: true)
        ActiveRecord::Migration.add_column(name, :story_created, :boolean)
        ActiveRecord::Migration.add_column(name, :client_id, :integer)
        ActiveRecord::Migration.add_column(name, :client_name, :string)
        ActiveRecord::Migration.add_column(name, :project_id, :integer)
        ActiveRecord::Migration.add_column(name, :project_name, :string)
        ActiveRecord::Migration.add_column(name, :publish_on, :datetime)

      end
    end

    def self.columns(t_name)
      columns = []
      ActiveRecord::Base.connected_to(database: { slow: :hle }) do
        columns = ActiveRecord::Base.connection.execute(Queries.column_list(t_name)).to_a
        columns = Columns.transform_exist(columns)
      end

      columns
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

    def self.rename(curr_t_name, modify_t_name)
      return if curr_t_name.eql?(modify_t_name)

      %(RENAME TABLE `#{curr_t_name}` TO `#{modify_t_name}`;)
    end

    def self.purge(t_name, iteration)
      %(DELETE FROM TABLE `#{t_name}` WHERE iteration = "#{iteration}";)
    end

    def self.iteration(t_name, iteration)
      %(SELECT * FROM `#{t_name}` WHERE iteration = "#{iteration}";)
    end

    def self.drop(name)
      %(DROP TABLE `#{name}`;)
    end

    def self.truncate(name)
      %(TRUNCATE TABLE `#{name}` WHERE iteration = "#{}";)
    end
  end
end
