# frozen_string_literal: true

require 'hle/queries'

class StagingTable < ApplicationRecord # :nodoc:
  serialize :columns, JSON

  belongs_to :story

  def self.name_columns_from(params)
    {
      name: params[:staging_table].delete(:name),
      columns: Hle::Queries.transform(params)
    }
  end

  def generate
    ActiveRecord::Base.connection.execute(
        Hle::Queries.create_table(self)
    )
  end

  def exists?(name)
    ActiveRecord::Base.connections.table_exists?("#{name}_staging")
  end
end
