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

  def publication_ids
    Table.publication_ids(name)
  end

  def purge
    Table.purge_last_iteration(name)
  end

  def truncate
    self.class.connection.truncate(name)
  end

  def samples_set_not_created
    Table.samples_set_as_not_created(name)
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
    self.class.hle_db_action(name) do |name|
      ActiveRecord::Migration.create_table(name) do |t|
        t.datetime :created_at
        t.datetime :updated_at
        t.integer  :client_id
        t.string   :client_name
        t.integer  :publication_id
        t.string   :publication_name
        t.string   :organization_ids, limit: 2000
        t.boolean  :story_created, default: false
        t.string   :time_frame
      end

      ActiveRecord::Base.connection.exec_query(
        "ALTER TABLE `#{name}` CHANGE COLUMN created_at created_at "\
        'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP;'
      )
      ActiveRecord::Base.connection.exec_query(
        "ALTER TABLE `#{name}` CHANGE COLUMN updated_at updated_at "\
        'TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;'
      )
    end
  end

  def iteration_missing?
    self.class.hle_db_action(name) do |name|
      ActiveRecord::Base.connection.columns(name).find do |c|
        c.name.eql?('iter_id') && c.default.to_i.positive?
      end
    end
  end

  def add_iteration
    self.class.hle_db_action(name, story_type.iteration.id) do |name, iter_id|
      ActiveRecord::Migration.add_column(name, :iter_id, :integer, default: iter_id, after: :id)
      ActiveRecord::Migration.add_index(name, :iter_id, name: :iter)
    end
  end

  def exists?
    self.class.hle_db_action(name) do |name|
      ActiveRecord::Base.connection.table_exists?(name)
    end
  end

  def drop_table
    self.class.hle_db_action(name) do |name|
      ActiveRecord::Base.connection.drop_table(name)
    end
  end

  def self.hle_db_action(table_name = nil, curr_iter_id = nil)
    raise ArgumentError, 'No block given' unless block_given?

    ActiveRecord::Base.connected_to(database: { slow: :loki_story_creator }) do
      yield(table_name, curr_iter_id)
    end
  end
end
