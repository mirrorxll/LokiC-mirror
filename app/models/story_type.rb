# frozen_string_literal: true

class StoryType < ApplicationRecord
  after_create do
    create_template
    create_fact_checking_doc
    create_cron_tab
    create_reminder
    create_sidekiq_break

    data_set.client_publication_tags.each do |client_publication_tag|
      clients_publications_tags.create!(
        client: client_publication_tag.client,
        publication: client_publication_tag.publication,
        tag: client_publication_tag.tag
      )
    end

    record_to_change_history(self, 'created', name, editor)

    iter = iterations.create!(name: 'Initial', current_account: current_account)
    update(current_iteration: iter)
  end

  before_update -> { tracking_changes(StoryType) }

  validates_uniqueness_of :name, case_sensitive: true

  belongs_to :data_set,          counter_cache: true
  belongs_to :editor,            class_name: 'Account'
  belongs_to :developer,         optional: true, class_name: 'Account'
  belongs_to :level,             optional: true
  belongs_to :frequency,         optional: true
  belongs_to :photo_bucket,      optional: true
  belongs_to :current_iteration, optional: true, class_name: 'StoryTypeIteration'
  belongs_to :status,            optional: true

  has_one :staging_table, as: :staging_tableable
  has_one :template, as: :templateable
  has_one :fact_checking_doc, as: :fcdable
  has_one :cron_tab
  has_one :cron_tab_iteration, -> { where(cron_tab: true) }, class_name: 'StoryTypeIteration'
  has_one :reminder
  has_one :sidekiq_break, as: :breakable, class_name: 'SidekiqBreak'

  has_one_attached :code

  has_many :iterations, class_name: 'StoryTypeIteration'
  has_many :export_configurations
  has_many :configurations_no_tags, -> { where(tag: nil).or(where(skipped: true)) }, class_name: 'ExportConfiguration'
  has_many :stories
  has_many :clients_publications_tags, class_name: 'StoryTypeClientPublicationTag'
  has_many :excepted_publications
  has_many :clients, through: :clients_publications_tags
  has_many :tags, through: :clients_publications_tags
  has_many :change_history, as: :history
  has_many :alerts, as: :alert
  has_many :default_opportunities, class_name: 'StoryTypeDefaultOpportunity'
  has_many :opportunities, class_name: 'StoryTypeOpportunity'

  scope :with_developer, -> { where.not(developer: nil) }
  scope :with_code, -> { joins(:code_attachment) }
  scope :ongoing, lambda {
    joins(:status).where.not('statuses.name': ['canceled', 'migrated', 'not started', 'blocked', 'done'])
  }
  scope :not_cron, -> { joins(:cron_tab).where.not('cron_tabs.enabled': true) }
  scope :archived, -> { where(archived: true) }

  def id_name
    "##{id} #{name}"
  end

  def developer_fc_channel_name
    developer&.fact_checking_channel&.name
  end

  def iteration
    current_iteration
  end

  def download_code_from_db
    MiniLokiC::StoryTypeCode[self].download
  end

  def client_pl_ids
    clients_publications_tags.flat_map do |cl_p_t|
      if cl_p_t.client.name.eql?('Metric Media')
        Client.where('name LIKE :like', like: 'MM -%').map(&:pl_identifier)
      else
        cl_p_t.client.pl_identifier
      end
    end
  end

  def publication_pl_ids
    pubs = clients_publications_tags.where.not(tag: nil).flat_map do |cl_p_t|
      cl = cl_p_t.client

      cl_pubs =
        case cl_p_t.publication&.name
        when 'all local publications'
          cl.publications.where(statewide: false)
        when 'all statewide publications'
          cl.publications.where(statewide: true)
        when 'all publications', nil
          cl.publications
        else
          [cl_p_t.publication]
        end

      cl_pubs.map(&:pl_identifier)
    end

    (pubs. - excepted_publications.map(&:publication).map(&:pl_identifier)).uniq
  end

  def show_samples
    stories.where(show: true)
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

  def check_updates_developed?
    !reminder.has_updates.nil?
  end
end
