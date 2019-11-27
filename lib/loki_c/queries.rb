# frozen_string_literal: true

module LokiC
  module Queries # :nodoc:
    def self.create_table(params)
      q = %|CREATE TABLE IF NOT EXISTS `#{params[:name]}_staging` (id INT AUTO_INCREMENT PRIMARY KEY, |
      params[:columns].each { |column| q += %(`#{column[:name]}` #{column[:type]}, ) }
      q[0...-2] + ') ENGINE=INNODB;'
    end

    def self.alter_table(t_name, cur_col, mod_col)
      q = ["ALTER TABLE `#{t_name}_staging`"]
      Columns.dropped(cur_col, mod_col).each { |c| q << "DROP COLUMN `#{c['name']}`," }
      Columns.added(cur_col, mod_col).each { |c| q << "ADD COLUMN `#{c[:name]}` #{c[:type]}," }
      Columns.changed(cur_col, mod_col).each do |c|
        q << "CHANGE COLUMN `#{c[:old_name]}` `#{c[:new_name]}` #{c[:new_type]},"
      end

      q.count > 1 ? q.join(' ')[0..-2] + ';' : nil
    end

    def self.rename_table(curr_name, modify_name)
      return if curr_name.eql?(modify_name)

      %(RENAME TABLE `#{curr_name}_staging` TO `#{modify_name}_staging`;)
    end

    def self.transform(params = {})
      Ids.from_raw(params[:staging_table]).map do |id|
        {
          id: id,
          name: params[:staging_table][:"column_name_#{id}"],
          type: params[:staging_table][:"column_type_#{id}"]
        }
      end
    end
  end
end
