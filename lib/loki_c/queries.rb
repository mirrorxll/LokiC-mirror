# frozen_string_literal: true

module LokiC
  module Queries # :nodoc:
    def self.create_table
      ActiveRecord::Base.connected_to(database: { slow: :hle }) do
        ActiveRecord::Migration.create_table("il_parole_staging", if_not_exists: true)
        ActiveRecord::Migration.add_column("il_parole_staging", :story_created, :boolean)
        ActiveRecord::Migration.add_column("il_parole_staging", :client_id, :integer)
        ActiveRecord::Migration.add_column("il_parole_staging", :client_name, :string)
        ActiveRecord::Migration.add_column("il_parole_staging", :project_id, :integer)
        ActiveRecord::Migration.add_column("il_parole_staging", :project_name, :string)
        ActiveRecord::Migration.add_column("il_parole_staging", :publish_on, :datetime)
      end
    end

    def self.alter_table(t_name, cur_col, mod_col)
      q = ["ALTER TABLE `#{t_name}`"]
      Columns.dropped(cur_col, mod_col).each { |c| q << "DROP COLUMN `#{c['name']}`," }
      Columns.added(cur_col, mod_col).each { |c| q << "ADD COLUMN `#{c[:name]}` #{c[:type]}," }
      Columns.changed(cur_col, mod_col).each do |c|
        q << "CHANGE COLUMN `#{c[:old_name]}` `#{c[:new_name]}` #{c[:new_type]},"
      end

      q.count > 1 ? q.join(' ')[0..-2] + ';' : nil
    end

    def self.rename_table(curr_t_name, modify_t_name)
      return if curr_t_name.eql?(modify_t_name)

      %(RENAME TABLE `#{curr_t_name}` TO `#{modify_t_name}`;)
    end

    def self.delete_population(t_name, iteration)
      %(DELETE FROM TABLE `#{t_name}` WHERE iteration = "#{iteration}";)
    end

    def self.select_iteration(t_name, iteration)
      %(SELECT * FROM `#{t_name}` WHERE iteration = "#{iteration}";)
    end

    def self.delete_creation(t_name, iteration)
      # %(DELETE FROM TABLE `#{t_name}` WHERE iteration = "#{iteration}";)
    end

    def drop_table(name)
      %(DROP TABLE `#{name}`;)
    end

    def self.truncate(name)
      %(TRUNCATE TABLE `#{name}` WHERE iteration = "#{iteration}";)
    end
  end
end
