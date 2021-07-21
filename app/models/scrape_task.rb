# frozen_string_literal: true

class ScrapeTask < ApplicationRecord
  before_create do
    self.status = Status.find_by(name: 'not started')

    build_datasource_comment(subtype: 'datasource comment')
    build_scrape_ability_comment(subtype: 'scrape ability comment')
    build_status_comment(subtype: 'status comment')
    build_general_comment(subtype: 'general comment')
    build_scrape_instruction
    build_scrape_evaluation_doc
  end

  validates_presence_of   :name
  validates_uniqueness_of :name, case_sensitive: false
  validates :datasource_url, length: { maximum: 1000 }

  belongs_to :creator,   optional: true, class_name: 'Account'
  belongs_to :scraper,   optional: true, class_name: 'Account'
  belongs_to :frequency, optional: true
  belongs_to :status,    optional: true

  has_one :scrape_instruction
  has_one :scrape_evaluation_doc
  has_one :scrape_ability_comment, -> { where(subtype: 'scrape ability comment') }, as: :commentable, class_name: 'Comment'
  has_one :datasource_comment, -> { where(subtype: 'datasource comment') }, as: :commentable, class_name: 'Comment'
  has_one :status_comment, -> { where(subtype: 'status comment') }, as: :commentable, class_name: 'Comment'
  has_one :general_comment, -> { where(subtype: 'general comment') }, as: :commentable, class_name: 'Comment'
  has_one :data_set

  has_many :comments, as: :commentable

  def updated_early?
    updated_at > created_at
  end

  def gather_task_link
    return unless gather_task.present?

    "https://pipeline.locallabs.com/gather_tasks/#{gather_task}"
  end
end
