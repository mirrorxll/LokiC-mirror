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

  def modify(params)
    queries = [
      Hle::Queries.alter_table_add_columns(name, columns, params[:columns]),
      Hle::Queries.alter_table_drop_columns(name, columns, params[:columns]),
      Hle::Queries.alter_table_change_columns(name, columns, params[:columns])
    ]

    queries.compact.each { |q| ActiveRecord::Base.connection.execute(q) }

    params
  end

  def exists?(name)
    ActiveRecord::Base.connections.table_exists?("#{name}_staging")
  end
end
