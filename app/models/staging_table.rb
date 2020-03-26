# frozen_string_literal: true

require_relative '../../lib/loki_c/staging_table.rb'

class StagingTable < ApplicationRecord # :nodoc:
  serialize :columns, Hash
  serialize :indices, Hash

  before_create   :generate_table_name, if: :noname?
  before_create   :create_table, if: :not_exists?
  before_destroy  :drop_table, if: :exists?

  belongs_to :story_type

  def synchronization
    return if not_exists?

    columns = LokiC::StagingTable.columns(name)
    indices = LokiC::StagingTable.indices(name)

    update!(columns: columns, indices: indices)
  end

  def truncate
    ActiveRecord::Base.connection.truncate(name)
  end

  def modify_columns(mod_columns)
    LokiC::StagingTable.modify_columns(name, columns, mod_columns)
  end

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

  def self.exists?(name)
    ActiveRecord::Base.connection.table_exists?(name)
  end

  def self.not_exists?(name)
    !exists?(name)
  end

  private

  def noname?
    name.nil?
  end

  def generate_table_name
    self.name = "#{story_type.id}_staging"
  end

  def exists?
    ActiveRecord::Base.connection.table_exists?(name)
  end

  def not_exists?
    !exists?
  end

  def create_table
    ActiveRecord::Migration.create_table(name)
    ActiveRecord::Migration.add_column(name, :story_created, :boolean)
    ActiveRecord::Migration.add_column(name, :client_id, :integer)
    ActiveRecord::Migration.add_column(name, :client_name, :string)
    ActiveRecord::Migration.add_column(name, :project_id, :integer)
    ActiveRecord::Migration.add_column(name, :project_name, :string)
    ActiveRecord::Migration.add_column(name, :publish_on, :datetime)

    columns.each do |_id, col|
      ActiveRecord::Migration.add_column(name, col[:name], col[:type], col[:opts])
    end
  end

  def drop_table
    ActiveRecord::Base.connection.drop_table(name)
  end
end
