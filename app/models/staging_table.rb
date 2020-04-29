# frozen_string_literal: true

class StagingTable < ApplicationRecord # :nodoc:
  before_create   :generate_table_name, if: :noname?
  before_create   :create_table, if: :not_exists?
  before_create   :add_iteration, if: :iteration_missing?
  after_create    :sync
  before_destroy  :drop_table, if: :exists?

  belongs_to :story_type

  has_one :columns, dependent: :delete
  has_one :index,   dependent: :delete

  def sync
    return if not_exists?

    columns = Table.columns(name)
    index = Table.index(name)
    Columns.find_or_create_by(staging_table: self).update(list: columns)
    Index.find_or_create_by(staging_table: self).update(list: index)
  end

  def clients_publications
    Table.clients_publications(name)
  end

  def purge
    Table.purge_last_iteration(name, story_type.iteration.id)
  end

  def truncate
    self.class.connection.truncate(name)
  end

  def self.exists?(name)
    connection.table_exists?(name)
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

  def not_exists?
    !exists?
  end

  def create_table
    ActiveRecord::Migration.create_table(name) do |t|
      t.timestamps
      t.integer :client_id
      t.integer :publication_id
      t.string  :organization_ids, limit: 1000
      t.boolean :story_created
    end
  end

  def iteration_missing?
    !self.class.connection.columns(name).find do |c|
      c.name.eql?('iteration_id') && c.default.to_i.positive?
    end
  end

  def add_iteration
    ActiveRecord::Migration
      .add_column name, :iteration_id, :integer,
                  default: story_type.iteration.id,
                  after: :id

    ActiveRecord::Migration.add_index name, :iteration_id, name: :iteration
  end

  def exists?
    self.class.connection.table_exists?(name)
  end

  def drop_table
    self.class.connection.drop_table(name)
  end
end
