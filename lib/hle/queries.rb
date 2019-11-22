# frozen_string_literal: true

require_relative ''

module Hle
  module Queries # :nodoc:
    def self.create_table(params)
      query = %|CREATE TABLE IF NOT EXISTS `#{params[:name]}_staging` (id INT AUTO_INCREMENT PRIMARY KEY, |
      params[:columns].each do |column|
        query += %|`#{column['name']}` #{column['type']}, |
      end

      query[0...-2] + ") ENGINE=INNODB;"
    end

    def self.transform(params = {})
      index = 1
      columns = []

      loop do
        break if params[:staging_table][:"column_name_#{index}"].nil? ||
            params[:staging_table][:"column_type_#{index}"].nil?

        columns << {
          name: params[:staging_table][:"column_name_#{index}"],
          type: params[:staging_table][:"column_type_#{index}"]
        }
        index += 1
      end
      columns
    end
  end
end
