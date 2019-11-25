# frozen_string_literal: true

require_relative 'queries/columns'
require_relative 'queries/ids'

module Hle
  module Queries # :nodoc:
    def self.create_table(params)
      query = %|CREATE TABLE IF NOT EXISTS `#{params[:name]}_staging` (id INT AUTO_INCREMENT PRIMARY KEY, |
      params[:columns].each do |column|
        query += %(`#{column['name']}` #{column['type']}, )
      end

      query[0...-2] + ') ENGINE=INNODB;'
    end

    def self.alter_table_add_columns(table_name, curr_columns, modify_columns)
      columns = Columns.added(curr_columns, modify_columns)
      return if columns.empty?

      query = %(ALTER TABLE `#{table_name}_staging` ADD COLUMN )
      columns.each do |column|
        query += %(`#{column[:name]}` #{column[:type]}, )
      end

      query[0...-2] + ';'
    end

    def self.alter_table_drop_columns(table_name, curr_columns, modify_columns)
      columns = Columns.dropped(curr_columns, modify_columns)
      return if columns.empty?

      query = %(ALTER TABLE `#{table_name}_staging` DROP COLUMN )
      columns.each do |column|
        query += %(`#{column['name']}`, )
      end

      query[0...-2] + ';'
    end

    def self.alter_table_change_columns(table_name, curr_columns, modify_columns)
      columns = Columns.changed(curr_columns, modify_columns)
      return if columns.empty?

      query = %(ALTER TABLE `#{table_name}_staging` CHANGE COLUMN )
      columns.each do |column|
        query += %(`#{column[:old_name]}` `#{column[:new_name]}` #{column[:new_type]}, )
      end

      query[0...-2] + ';'
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
