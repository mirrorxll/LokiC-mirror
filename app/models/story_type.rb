# frozen_string_literal: true

class StoryType < ApplicationRecord # :nodoc:
  belongs_to :editor,               class_name: 'Account'
  belongs_to :developer,            optional: true, class_name: 'Account'
  belongs_to :data_set
  belongs_to :status,               optional: true
  belongs_to :frequency,            optional: true
  belongs_to :photo_bucket,         optional: true
  belongs_to :tag,                  optional: true

  has_one :staging_table
  has_one :template, dependent: :destroy

  has_many :story_type_iterations, dependent: :destroy
  has_and_belongs_to_many :clients

  has_one_attached :code

  validates :name, uniqueness: true

  before_create { build_template }
  before_create { self.status = Status.first }

  # filter
  def self.editor(id)
    where(writer_id: id)
  end

  def self.developer(id)
    where(developer_id: id)
  end

  def self.data_set(id)
    where(data_set_id: id)
  end

  def self.client(id)
    includes(:clients).where(clients: { id: id })
  end

  def self.frequency(id)
    includes(:frequencies).where(frequencies: { id: id })
  end

  def self.dev_status(dev_status)
    where(dev_status: dev_status)
  end
end
