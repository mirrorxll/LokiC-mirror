# frozen_string_literal: true

require_relative '../../lib/loki_c/staging_table.rb'

class StagingTable < ApplicationRecord # :nodoc:
  serialize :editable, Hash

  belongs_to :story_type

  before_create { self.name = "#{story_type.id}_staging" }

  def tbl_columns
    LokiC::StagingTable.columns(name)
  end

  def create_tbl(columns)
    LokiC::StagingTable.create(name, columns)
  end

  def drop_tbl
    LokiC::StagingTable.drop(name)
  end

  def truncate_tbl
    LokiC::StagingTable.truncate(name)
  end

  def prepare_editable
    self.editable = LokiC::StagingTable.columns_by_hex(name)

    save
  end

  # def modify(params)
  #   queries = [
  #     'BEGIN;',
  #     LokiC::Queries.alter_table(name, columns, params[:columns]),
  #     'COMMIT;',
  #     LokiC::Queries.rename_table(name, params[:name])
  #   ]
  #
  #   queries.compact.each { |q| ActiveRecord::Base.connection.execute(q) }
  #   nil
  # rescue ActiveRecord::StatementInvalid => e
  #   ActiveRecord::Base.connection.execute('ROLLBACK;')
  #   e.message
  # end
  #
  # def execute_code(method, options)
  #   ex = LokiC::StoryType::Code.run(story_type, method, options)
  #   story_type.story_type_iterations.last.update!("#{method}_status": 1) unless ex
  #
  #   ex
  # end
  #
  # def rows(number)
  #   ActiveRecord::Base.connection.execute(
  #     LokiC::Queries.select_iteration(name, number)
  #   )
  # end
  #
  # def purge_last_population
  #   ActiveRecord::Base.connection.execute(
  #     LokiC::Queries.delete_population(name, story.iterations.last)
  #   )
  # end
  #
  # def purge_last_creation
  #   ActiveRecord::Base.connection.execute(
  #     LokiC::Queries.delete_creation(name, story.iterations.last)
  #   )
  # end

  def self.tbl_exists?(t_name)
    LokiC::StagingTable.exists?(t_name)
  end
end
