# frozen_string_literal: true

require 'hle/queries'

class StagingTable < ApplicationRecord # :nodoc:
  serialize :columns, JSON

  belongs_to :story

  def self.transform(params)
    index = 1
    table_params = { name: params[:staging_table].delete(:name), columns: [] }

    loop do
      break if params[:staging_table][:"column_name_#{index}"].nil? ||
          params[:staging_table][:"column_type_#{index}"].nil?

      table_params[:columns] << {
          "#{params[:staging_table][:"column_name_#{index}"]}":
              params[:staging_table][:"column_type_#{index}"]
      }
      index += 1
    end

    puts table_params
    table_params
  end

  def generate
    ActiveRecord::Base.connection.execute(
        Hle::Queries.create_table(self)
    )
  end
end
