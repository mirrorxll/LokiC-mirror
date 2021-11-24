# frozen_string_literal: true

class ScrapeTask < ApplicationRecord
  before_create do
    self.status = Status.find_by(name: 'not started')

    build_datasource_comment(subtype: 'datasource comment')
    build_scrape_ability_comment(subtype: 'scrape ability comment')
    build_status_comment(subtype: 'status comment')
    build_general_comment(subtype: 'general comment')
    build_instruction
    build_evaluation_doc
  end

  after_create { record_to_change_history(self, 'created', name, creator) }
  before_update :tracking_changes

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive: false
  validates :datasource_url, length: { maximum: 1000 }

  belongs_to :multi_task, optional: true, class_name: 'Task', foreign_key: :task_id
  belongs_to :creator,    optional: true, class_name: 'Account'
  belongs_to :scraper,    optional: true, class_name: 'Account'
  belongs_to :frequency,  optional: true
  belongs_to :status,     optional: true
  belongs_to :state,      optional: true

  has_one :instruction, class_name: 'ScrapeInstruction'
  has_one :evaluation_doc, class_name: 'ScrapeEvaluationDoc'
  has_one :scrape_ability_comment, -> { where(subtype: 'scrape ability comment') }, as: :commentable, class_name: 'Comment'
  has_one :datasource_comment,     -> { where(subtype: 'datasource comment') }, as: :commentable, class_name: 'Comment'
  has_one :status_comment,         -> { where(subtype: 'status comment') }, as: :commentable, class_name: 'Comment'
  has_one :general_comment,        -> { where(subtype: 'general comment') }, as: :commentable, class_name: 'Comment'
  has_one :data_set

  has_many :change_history, as: :history
  has_many :alerts, as: :alert

  has_and_belongs_to_many :tags, class_name: 'ScrapeTaskTag'

  def updated_early?
    updated_at > created_at
  end

  def gather_task_link
    return unless gather_task.present?

    "https://pipeline.locallabs.com/gather_tasks/#{gather_task}"
  end

  def scraper_slack_id
    scraper&.slack&.identifier
  end

  private

  def tracking_changes
    changes = {}
    changes['renamed'] = "#{name_change.first} -> #{name}" if name_changed?
    changes['evaluated'] = "#{evaluation_change.first} -> #{evaluation}" if evaluation_changed?
    changes['datasource url changed'] = "#{datasource_url_change.first} -> #{datasource_url}" if datasource_url_changed?

    if scrapable_changed?
      scrapable_changes = scrapable_change.first.eql?(-1) ? 'not checked' : "#{scrapable_change.first} -> #{scrapable}"
      changes['scrapable status changed'] = scrapable_changes
    end

    if scraper_id_changed?
      old_scraper = Account.find_by(id: scraper_id_change.first)
      new_scraper = scraper

      old_scraper_name = old_scraper&.name || 'not distributed'
      new_scraper_name = new_scraper&.name || 'not distributed'
      changes['distributed'] = "#{old_scraper_name} -> #{new_scraper_name}"

      ScrapeTasks::SlackNotificationJob.perform_now(self, 'scraper', 'Unpinned', old_scraper) if old_scraper
      ScrapeTasks::SlackNotificationJob.perform_now(self, 'scraper', 'Distributed to you', new_scraper) if new_scraper
    end

    if status_id_changed?
      old_status_name = Status.find_by(id: status_id_change.first).name
      new_status_name = status.name.in?(%w[blocked canceled]) ? "#{status.name}: #{status_comment.reload&.body}" : status.name
      changes['progress status changed'] = "#{old_status_name} -> #{new_status_name}"

      ScrapeTasks::SlackNotificationJob.perform_now(self, 'status', changes['progress status changed'], current_account)
    end

    if frequency_id_changed?
      old_frequency_name = Frequency.find_by(id: frequency_id_change.first)&.name || 'not selected'
      new_frequency_name = frequency&.name || 'not selected'
      changes['frequency changed'] = "#{old_frequency_name} -> #{new_frequency_name}"
    end

    if state_id_changed?
      old_state_name = State.find_by(id: state_id_change.first)&.name || 'not selected'
      new_state_name = state&.name || 'not selected'
      changes['state changed'] = "#{old_state_name} -> #{new_state_name}"
    end

    if gather_task_changed?
      old_gather_task_name = gather_task_change.first || 'not attached'
      new_gather_task_name = gather_task || 'not attached'
      changes['gather task changed'] = "#{old_gather_task_name} -> #{new_gather_task_name}"
    end

    if data_set_location_changed?
      old_location = data_set_location_change.first.present? ? data_set_location_change.first : 'not attached'
      new_location = data_set_location.present? ? data_set_location : 'not attached'
      changes['data set location changed'] = "#{old_location} -> #{new_location}"
    end

    changes.each { |ev, ch| record_to_change_history(self, ev, ch, current_account) }
  end
end
