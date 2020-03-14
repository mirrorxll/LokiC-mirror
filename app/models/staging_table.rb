# frozen_string_literal: true

require_relative '../../lib/loki_c/staging_table/columns.rb'
require_relative '../../lib/loki_c/staging_table/ids.rb'

class StagingTable < ApplicationRecord # :nodoc:
  before_create { self.name = "#{story_type.id}_staging" }

  belongs_to :story_type

  def attach_tbl(table)
    LokiC::StagingTable.attach(table[:name])
  end

  def create_tbl(columns)
    LokiC::StagingTable.create(name, columns)
  end

  def columns_list
    LokiC::StagingTable.columns(name)
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

  def execute_code(method, options)
    ex = LokiC::StoryType::Code.run(story_type, method, options)
    story_type.story_type_iterations.last.update!("#{method}_status": 1) unless ex

    ex
  end

  def rows(number)
    ActiveRecord::Base.connection.execute(
      LokiC::Queries.select_iteration(name, number)
    )
  end

  def purge_last_population
    ActiveRecord::Base.connection.execute(
      LokiC::Queries.delete_population(name, story.iterations.last)
    )
  end

  def purge_last_creation
    ActiveRecord::Base.connection.execute(
      LokiC::Queries.delete_creation(name, story.iterations.last)
    )
  end

  def drop_table
    ActiveRecord::Base.connection.execute(
      LokiC::Queries.drop_table(name)
    )
  end

  def truncate
    ActiveRecord::Base.connection.execute(
      LokiC::Queries.truncate(name)
    )
  end
end
