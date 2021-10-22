# frozen_string_literal: true

class StagingTable < ApplicationRecord # :nodoc:
  before_create do
    attach_table_name if noname?
    create_table if not_exists?

    default_iter_id

    if story_type?
      default_story_type_columns
      delete_useless_columns
      add_story_created
    elsif article_type?
      add_article_created
    end

    rename_table if not_lokic_name?
    timestamps
  end
  after_create :sync

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

  def default_iter_id(id = nil)
    iter_id = id || staging_tableable.iteration.id
    Table.iter_id_column(name, iter_id)
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

  def not_lokic_name?
    !name.match?(/^[as]\d{4,5}$/)
  end

  def generate_table_name
    "#{staging_tableable.class.to_s.downcase.first}#{staging_tableable.id.to_s.rjust(4, '0')}"
  end

  def attach_table_name
    self.name = generate_table_name
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

  def rename_table
    self.old_name = name
    self.name = generate_table_name

    Table.rename_table(old_name, name)
  end
end
