# frozen_string_literal: true

class StoryType < ApplicationRecord
  before_create do
    self.photo_bucket = data_set.photo_bucket
    build_template
    build_fact_checking_doc
    build_reminder
    iterations.build(name: 'Initial')
  end

  after_create do
    data_set.client_publication_tags.each do |client_publication_tag|
      clients_publications_tags.create!(
        client: client_publication_tag.client,
        publication: client_publication_tag.publication,
        tag: client_publication_tag.tag
      )
    end

    event = HistoryEvent.find_by(name: 'created')
    change_history.create!(history_event: event, notes: "created by #{editor.name}")

    update(current_iteration: iterations.first)
  end

  validates_uniqueness_of :name, case_sensitive: true

  belongs_to :editor,            class_name: 'Account'
  belongs_to :developer,         optional: true, class_name: 'Account'
  belongs_to :data_set,          counter_cache: true
  belongs_to :frequency,         optional: true
  belongs_to :photo_bucket,      optional: true
  belongs_to :current_iteration, optional: true, class_name: 'Iteration'
  belongs_to :status,            optional: true

  has_one :staging_table
  has_one :template
  has_one :fact_checking_doc
  has_one :cron_tab
  has_one :reminder

  has_one_attached :code

  has_many :iterations
  has_many :export_configurations
  has_many :configurations_no_tags, -> { where(tag: nil).or(where(skipped: true)) }, class_name: 'ExportConfiguration'
  has_many :samples
  has_many :clients_publications_tags, class_name: 'StoryTypeClientPublicationTag'
  has_many :clients, through: :clients_publications_tags
  has_many :tags, through: :clients_publications_tags
  has_many :change_history, as: :history
  has_many :alerts, as: :alert

  def publications
    pub_ids = clients.map(&:publications).reduce(:|).map(&:id)
    Publication.where(id: pub_ids)
  end

  def number_name
    "##{id} #{name}"
  end

  def developer_slack_id
    developer&.slack&.identifier
  end

  def developer_fc_channel_name
    developer&.fc_channel&.name
  end

  def iteration
    current_iteration
  end

  def download_code_from_db
    MiniLokiC::Code[self].download
  end

  def client_pl_ids
    clients_publications_tags.flat_map do |cl_t|
      if cl_t.client.name.eql?('Metric Media')
        Client.where('name LIKE :like', like: 'MM -%').map(&:pl_identifier)
      else
        cl_t.client.pl_identifier
      end
    end
  end

  def show_samples
    samples.where(show: true)
  end

  def first_show_sample
    smpls = show_samples.reverse
    smpls.count.positive? ? smpls.first : nil
  end

  def second_show_sample
    smpls = show_samples.reverse
    smpls.count > 1 ? smpls.second : nil
  end

  def third_show_sample
    smpls = show_samples.reverse
    smpls.count > 2 ? smpls.last : nil
  end

  def reminder_off?
    return false unless reminder&.turn_off_until

    reminder.turn_off_until > Date.today
  end

  def reminder_on?
    !reminder_off?
  end

  def updates?
    reminder&.has_updates
  end

  def updates_confirmed?
    reminder&.updates_confirmed
  end
end
