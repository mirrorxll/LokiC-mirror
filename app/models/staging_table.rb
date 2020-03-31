# frozen_string_literal: true

class StagingTable < ApplicationRecord # :nodoc:
  before_create   :generate_table_name, if: :noname?
  before_create   :create_table, if: :not_exists?
  after_create    :sync
  before_destroy  :drop_table, if: :exists?

  belongs_to :story_type

  has_one :columns, dependent: :delete
  has_one :index,   dependent: :delete

  def sync
    return if not_exists?

    columns = LokiC::StagingTable.columns(name)
    puts index = LokiC::StagingTable.index(name)
    Columns.find_or_create_by(staging_table: self).update(list: columns)
    Index.find_or_create_by(staging_table: self).update(list: index)
  end

  def truncate
    ActiveRecord::Base.connection.truncate(name)
  end

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
    ActiveRecord::Migration.create_table(name) do |t|
      t.timestamps
      t.integer :client_id
      t.string  :client_name
      t.integer :publication_id
      t.string  :publication_name
      t.string  :organization_id, limit: 1000
      t.date    :publish_on
      t.boolean :story_created
    end
  end

  def drop_table
    ActiveRecord::Base.connection.drop_table(name)
  end
end
