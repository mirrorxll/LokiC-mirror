# frozen_string_literal: true

class StagingTable < ApplicationRecord # :nodoc:
  before_create :generate_table_name,        if: :noname?
  before_create :create_table,               if: :not_exists?
  before_create :default_iter_id
  before_create :default_story_type_columns, if: :story_type?
  before_create :delete_useless_columns,     if: :story_type?
  before_create :add_story_created,          if: :story_type?
  before_create :add_article_created,        if: :article_type?
  before_create :timestamps
  after_create  :sync

  belongs_to :staging_tableable, polymorphic: true

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
    Columns.find_or_create_by(staging_table: self).update!(list: columns)
    index = Table.index(name)
    Index.find_or_create_by(staging_table: self).update!(list: index)

    nil
  end

  def default_iter_id
    Table.iter_id_column(name, staging_tableable.iteration.id)
  end

  def publication_ids
    pub_ids = staging_tableable.publication_pl_ids
    Table.publication_ids(name, pub_ids)
  end

  def purge
    Table.purge_last_iteration(name)
  end

  private

  def story_type?
    staging_tableable.class.to_s.eql?('StoryType')
  end

  def article_type?
    staging_tableable.class.to_s.eql?('ArticleType')
  end

  def noname?
    name.nil? || name.empty?
  end

  def not_exists?
    !self.class.exists?(name)
  end

  def generate_table_name
    self.name = "#{staging_tableable.class.to_s.underscore}_#{staging_tableable.id.to_s.rjust(5, '0')}_staging"
  end

  def create_table
    Table.create(name)
  end

  def default_story_type_columns
    Table.add_default_story_type_columns(name)
  end

  def delete_useless_columns
    Table.delete_useless_columns(name)
  end

  def add_story_created
    Table.add_story_created(name)
  end

  def add_article_created
    Table.add_article_created(name)
  end

  def timestamps
    Table.timestamps(name)
  end
end
