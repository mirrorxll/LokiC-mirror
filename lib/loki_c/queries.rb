# frozen_string_literal: true

module LokiC
  module Queries # :nodoc:
    def self.create_table(params)
      q = "CREATE TABLE IF NOT EXISTS `#{params[:name]}_staging` ("\
           'id INT AUTO_INCREMENT PRIMARY KEY, '\
           'source_table_id INT, '\
           'client_id INT, '\
           'client_name VARCHAR(255), '\
           'project_id INT, '\
           'project_name VARCHAR(255), '\
           'publish_on VARCHAR(10), '
      params[:columns].each { |column| q += %(`#{column[:name]}` #{column[:type]}, ) }
      q[0...-2] + ') ENGINE=INNODB;'
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
