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

  def self.generate(params)
    ActiveRecord::Base.connection.execute(
      Hle::Queries.create_table(params)
    )

  rescue ActiveRecord::StatementInvalid => e
    e.message
  end

  def modify(params)
    queries = [
      'BEGIN;',
      Hle::Queries.alter_table(name, columns, params[:columns]),
      Hle::Queries.rename_table(name, params[:name]),
      'COMMIT;'
    ]

    queries.compact.each { |q| ActiveRecord::Base.connection.execute(q) }
    nil
  rescue ActiveRecord::StatementInvalid => e
    ActiveRecord::Base.connection.execute('ROLLBACK;')
    e.message
  end

  def exists?(name)
    ActiveRecord::Base.connections.table_exists?("#{name}_staging")
  end
end
