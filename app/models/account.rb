# frozen_string_literal: true

class Account < ApplicationRecord # :nodoc:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :account_types

  has_one :slack, class_name: 'SlackAccount'
  has_one :fact_checking_channel

  has_many :data_sets
  has_many :sheriffs,              foreign_key: :sheriff_id,            class_name: 'DataSet'
  has_many :responsible_editor,    foreign_key: :responsible_editor_id, class_name: 'DataSet'
  has_many :edit_story_types,      foreign_key: :editor_id,             class_name: 'StoryType'
  has_many :edit_article_types,    foreign_key: :editor_id,             class_name: 'ArticleType'
  has_many :dev_story_types,       foreign_key: :developer_id,          class_name: 'StoryType'
  has_many :dev_article_types,     foreign_key: :developer_id,          class_name: 'ArticleType'
  has_many :submitters,            foreign_key: :submitter_id,          class_name: 'PostExportReport'
  has_many :created_scrape_tasks,  foreign_key: :creator_id,            class_name: 'ScrapeTask'
  has_many :assigned_scrape_tasks, foreign_key: :scraper_id,            class_name: 'ScrapeTask'
  has_many :production_removals
  has_many :comments,              foreign_key: :commentator_id
  has_many :assigned_scrape_tasks, foreign_key: :scraper_id,            class_name: 'ScrapeTask'
  has_many :created_scrape_tasks,  foreign_key: :creator_id,            class_name: 'ScrapeTask'

  scope :get_accounts, -> (account_type) { joins(:account_types).where('account_types.name': account_type) }

  def name
    "#{first_name} #{last_name}"
  end

  def types
    account_types.map(&:name)
  end

  def slack_identifier
    slack&.identifier
  end
end
