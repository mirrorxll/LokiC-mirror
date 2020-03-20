# frozen_string_literal: true


module LokiC
  module StagingTable # :nodoc:
    require_relative 'staging_table/queries.rb'
    require_relative 'staging_table/columns.rb'

    def self.exists?(t_name)
      ActiveRecord::Base.connection.table_exists?(t_name)
    end

    def self.attach(t_name)
      columns = ActiveRecord::Base.connection.execute(Queries.column_list(t_name))
      columns = Ids.transform(columns)
    end

    def self.create(t_name, columns)
      ActiveRecord::Migration.create_table(t_name, if_not_exists: true)
      ActiveRecord::Migration.add_column(t_name, :story_created, :boolean)
      ActiveRecord::Migration.add_column(t_name, :client_id, :integer)
      ActiveRecord::Migration.add_column(t_name, :client_name, :string)
      ActiveRecord::Migration.add_column(t_name, :project_id, :integer)
      ActiveRecord::Migration.add_column(t_name, :project_name, :string)
      ActiveRecord::Migration.add_column(t_name, :publish_on, :datetime)

      columns.each do |c_name, c_type|
        ActiveRecord::Migration.add_column(t_name, c_name, c_type[0], c_type[1].symbolize_keys)
      end
    end

    def self.columns(t_name)
      columns = ActiveRecord::Base.connection.execute(Queries.column_list(t_name)).to_a
      Columns.transform_exist(columns)
    end

    def self.columns_by_hash(t_name)
      hashed = columns(t_name).map { |t, n| { SecureRandom.hex(3) => { t => n } } }
      hashed.reduce(:merge)
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
