# frozen_string_literal: true

class StagingTable < ApplicationRecord # :nodoc:
  before_create   :generate_table_name, if: :noname?
  before_create   :create_table,        if: :not_exists?
  before_create   :default_iter_id
  before_create   :timestamps
  after_create    :sync

  belongs_to :story_type

  has_one :columns, dependent: :delete
  has_one :index,   dependent: :delete

  def self.exists?(name)
    return unless name

    Table.exists?(name)
  end

  def self.not_exists?(name)
    !exists?(name)
  end

  def sync
    columns = Table.columns(name)
    Columns.find_or_create_by(staging_table: self).update(list: columns)
    index = Table.index(name)
    Index.find_or_create_by(staging_table: self).update(list: index)

    nil
  end

  def default_iter_id
    Table.iter_id_column(name, story_type.iteration.id)
  end

  def publication_ids
    Table.publication_ids(name)
  end

  def purge
    Table.purge_last_iteration(name)
  end

  def samples_set_not_created
    Table.samples_set_as_not_created(name)
  end

  private

  def noname?
    name.nil?
  end

  def not_exists?
    !self.class.exists?(name)
  end

  def generate_table_name
    self.name = "s#{story_type.id}_staging"
  end

  def create_table
    Table.create(name)
  end

  def timestamps
    Table.timestamps(name)
  end
end
