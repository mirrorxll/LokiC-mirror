# frozen_string_literal: true

class StoryType < ApplicationRecord # :nodoc:
  default_scope { order(created_at: :desc) }

  has_one_attached :code

  belongs_to :editor,     class_name: 'User'
  belongs_to :developer,  class_name: 'User', optional: true
  belongs_to :data_location

  has_one :staging_table
  has_many :story_type_iterations, dependent: :destroy

  has_and_belongs_to_many :clients,         join_table: 'story_types__clients'
  has_and_belongs_to_many :sections,        join_table: 'story_types__sections'
  has_and_belongs_to_many :tags,            join_table: 'story_types__tags'
  has_and_belongs_to_many :photo_buckets,   join_table: 'story_types__photo_buckets'
  has_and_belongs_to_many :levels,          join_table: 'story_types__levels'
  has_and_belongs_to_many :frequencies,     join_table: 'story_types__frequencies'

  def filename
    "StoryType#{id}"
  end
  alias module_name filename

  # filter
  def self.writer(id)
    where(writer_id: id)
  end

  def self.developer(id)
    where(developer_id: id)
  end

  def self.client(id)
    includes(:clients).where(clients: { id: id })
  end

  def self.level(id)
    includes(:levels).where(levels: { id: id })
  end

  def self.frequency(id)
    includes(:frequencies).where(frequencies: { id: id })
  end

  def self.dev_status(dev_status)
    where(dev_status: dev_status)
  end
end
