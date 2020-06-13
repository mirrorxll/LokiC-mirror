# frozen_string_literal: true

class StoryType < ApplicationRecord # :nodoc:
  belongs_to :editor,       class_name: 'Account'
  belongs_to :developer,    optional: true, class_name: 'Account'
  belongs_to :data_set
  belongs_to :status,       optional: true
  belongs_to :frequency,    optional: true
  belongs_to :photo_bucket, optional: true

  has_one :staging_table
  has_one :template, dependent: :destroy

  has_many :iterations,             dependent: :destroy
  has_many :export_configurations,  dependent: :destroy
  has_many :configurations_no_tags, -> { where(tag: nil, skipped: [false, nil]) }, class_name: 'ExportConfiguration'

  has_many :client_tags, class_name: 'StoryTypeClientTag'
  has_many :clients, through: :client_tags

  has_one_attached :code

  validates :name, uniqueness: true

  before_create { build_template }
  before_create { self.status = Status.first }
  before_create { iterations.build }

  def developer_slack_id
    developer&.slack&.identifier
  end

  def iteration
    iterations.last
  end

  # method will update last iteration status
  # possible keys:
  # population, export_configuration,
  # samples, creation, export
  # -----------------
  # possible values:
  # nil - not started
  # false - in progress
  # true - success
  def update_iteration(status = {})
    return if status.empty?

    iteration.update(status)
  end

  def download_code_from_db
    MiniLokiC::Code.download(self)
  end

  # filter
  def self.editor(id)
    where(editor_id: id)
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
    where(frequency: id)
  end

  def self.status(id)
    where(status: id)
  end
end
