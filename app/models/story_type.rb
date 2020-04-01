# frozen_string_literal: true

class StoryType < ApplicationRecord # :nodoc:
  has_one_attached :code

  belongs_to :editor,     class_name: 'User'
  belongs_to :developer,  class_name: 'User', optional: true
  belongs_to :data_set

  has_one :staging_table
  has_many :story_type_iterations, dependent: :destroy

  has_and_belongs_to_many :clients,         join_table: 'story_types__clients'
  has_and_belongs_to_many :sections,        join_table: 'story_types__sections'
  has_and_belongs_to_many :tags,            join_table: 'story_types__tags'
  has_and_belongs_to_many :photo_buckets,   join_table: 'story_types__photo_buckets'
  has_and_belongs_to_many :levels,          join_table: 'story_types__levels'
  has_and_belongs_to_many :frequencies,     join_table: 'story_types__frequencies'

  after_initialize :prepare_template_body

  validates :name, uniqueness: true

  def body_formatted
    LokiC::StoryType.format_body(body)
  end

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

  private

  def prepare_template_body
    return unless new_record?

    self.body =
      '<p><b>HEADLINE:</b>&nbsp;</p><p><span style="font-size: 1rem;">'\
      '<b>TEASER</b>:&nbsp;</span></p><p><b>BODY:</b>&nbsp;</p><p><b><br></b></p>'
  end
end
