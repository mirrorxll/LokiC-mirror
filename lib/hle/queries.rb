# frozen_string_literal: true

require_relative 'queries/columns'

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
      query = %(ALTER TABLE #{table_name} )
      Columns.added(curr_columns, modify_columns).each do |column|
        query += %(ADD COLUMN #{column['name']} #{column['type']}, )
      end

      query[0...-2] + ';'
    end

    def self.alter_table_drop_columns(table_name, curr_columns, modify_columns)
      query = %(ALTER TABLE #{table_name} )
      Columns.dropped(curr_columns, modify_columns).each do |column|
        query += %(DROP COLUMN #{column['name']}, )
      end

      query[0...-2] + ';'
    end

    def self.alter_table_change_columns(table_name, curr_columns, modify_columns)
      query = %(ALTER TABLE #{table_name} )
      Columns.changed(curr_columns, modify_columns).each do |column|
        query += %(CHANGE COLUMN #{column['old_name']} #{column['new_name']} #{column['type']}, )
      end

      query[0...-2] + ';'
    end

    def self.transform(params = {})
      Columns.ids(params[:staging_table]).map do |id|
        {
          id: id,
          name: params[:staging_table][:"column_name_#{id}"],
          type: params[:staging_table][:"column_type_#{id}"]
        }
      end
    end
  end
end
