# frozen_string_literal: true

require_relative ''

module Hle
  module Queries # :nodoc:
    def self.create_table(params)
      query = %|CREATE TABLE IF NOT EXISTS `#{params[:name]}_staging` (id INT AUTO_INCREMENT PRIMARY KEY, |
      params[:columns].each do |column|
        name, type = column.first.to_a
        puts name, type
        query += %|`#{name}` #{type}, |
      end

      query[0...-2] + ") ENGINE=INNODB;"
    end
  end
end
