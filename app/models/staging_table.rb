# frozen_string_literal: true

require 'loki_c/queries'

class StagingTable < ApplicationRecord # :nodoc:
  serialize :columns, JSON

  belongs_to :story

  def self.name_columns_from(params)
    {
      name: params[:staging_table].delete(:name),
      columns: LokiC::Queries.transform(params)
    }
  end

  def self.generate(params)
    ActiveRecord::Base.connection.execute(
      LokiC::Queries.create_table(params)
    )
  rescue ActiveRecord::StatementInvalid => e
    e.message
  end

  def modify(params)
    queries = [
      'BEGIN;',
      LokiC::Queries.alter_table(name, columns, params[:columns]),
      'COMMIT;',
      LokiC::Queries.rename_table(name, params[:name])
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
