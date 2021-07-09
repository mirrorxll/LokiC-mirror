# frozen_string_literal: true

class ScrapeTask < ApplicationRecord
  before_create do
    self.status = Status.find_by(name: 'not started')
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
  has_one :scrape_ability_comment, -> { includes(:comment_subtype).where(comment_subtypes: { name: 'scrape_ability_comment' }) }, as: :commentable, class_name: 'Comment'
  has_one :datasource_comment, -> { includes(:comment_subtype).where(comment_subtypes: { name: 'datasource comment' }) }, as: :commentable, class_name: 'Comment'
  has_one :status_comment, -> { includes(:comment_subtype).where(comment_subtypes: { name: 'status comment' }) }, as: :commentable, class_name: 'Comment'

  def updated_early?
    updated_at > created_at
  end

  def gather_task_link
    return unless gather_task

    "https://pipeline.locallabs.com/gather_tasks/#{gather_task}"
  end
end
