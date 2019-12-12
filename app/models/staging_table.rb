# frozen_string_literal: true

require 'loki_c/queries'

class StagingTable < ApplicationRecord # :nodoc:
  serialize :columns, JSON

  belongs_to :story

  def self.name_columns_from(params)
    {
      name: params[:staging_table].delete(:name),
      columns: LokiC::Queries::Columns.transform(params)
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

  def execute_population(options)
    if story.story_iterations.count.zero? || story.story_iterations.last.populate_status
      story.story_iterations.create
    end

    ex = LokiC::Story::Population.run(story, options)
    story.story_iterations.last.update!(populate_status: 1) if ex
  end

  def purge_last_population
    ActiveRecord::Base.connection.execute(
      LokiC::Queries.delete_from(name, story.iterations.last)
    )
  end

  def execute_creation(options)

  end

  def purge_last_creation

  end
end
