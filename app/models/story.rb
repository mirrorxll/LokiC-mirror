# frozen_string_literal: true

class Story < ApplicationRecord # :nodoc:
  default_scope { order(created_at: :desc) }

  has_rich_text :body

  belongs_to :writer,     class_name: 'User'
  belongs_to :developer,  class_name: 'User', optional: true

  has_and_belongs_to_many :clients,         join_table: 'stories__clients'
  has_and_belongs_to_many :data_locations,  join_table: 'stories__data_locations'
  has_and_belongs_to_many :sections,        join_table: 'stories__sections'
  has_and_belongs_to_many :tags,            join_table: 'stories__tags'
  has_and_belongs_to_many :photo_buckets,   join_table: 'stories__photo_buckets'
  has_and_belongs_to_many :levels,          join_table: 'stories__levels'
  has_and_belongs_to_many :frequencies,     join_table: 'stories__frequencies'

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

  def self.status(status)
    where(status: status)
  end
end
