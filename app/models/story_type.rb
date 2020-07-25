# frozen_string_literal: true

class StoryType < ApplicationRecord # :nodoc:
  belongs_to :editor,            class_name: 'Account'
  belongs_to :developer,         optional: true, class_name: 'Account'
  belongs_to :data_set
  belongs_to :frequency,         optional: true
  belongs_to :photo_bucket,      optional: true
  belongs_to :current_iteration, optional: true, class_name: 'Iteration'

  has_one :staging_table
  has_one :template, dependent: :destroy
  has_one :fact_checking_doc

  has_many :iterations,             dependent: :destroy
  has_many :export_configurations,  dependent: :destroy
  has_many :configurations_no_tags, -> { where(tag: nil).or(where(skipped: true)) }, class_name: 'ExportConfiguration'

  has_many :client_tags, class_name: 'StoryTypeClientTag'
  has_many :clients, through: :client_tags

  has_one_attached :code

  validates :name, uniqueness: true

  before_create do
    build_template
    build_fact_checking_doc
    iterations.build(name: 'Initial')
  end

  after_create { update(current_iteration: iterations.first) }

  def developer_slack_id
    developer&.slack&.identifier
  end

  def iteration
    current_iteration
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
    iteration.statuses.find_by(id: id)
  end
end
