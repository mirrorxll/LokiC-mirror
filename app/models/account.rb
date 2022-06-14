# frozen_string_literal: true

class Account < ApplicationRecord # :nodoc:
  alias_attribute :password_digest, :encrypted_password

  has_secure_password

  before_create do
    generate_token(:auth_token)
    self.status = Status.find_by(name: 'active')
  end

  after_create do
    Branch.find_each do |b|
      user_access = AccessLevel.find_by(branch: b, name: 'guest')

      AccountCard.create!(
        account: self,
        branch: b,
        access_level: user_access
      )
    end
  end

  belongs_to :status, optional: true
  belongs_to :creator, class_name: 'Account', optional: true

  has_one :slack, class_name: 'SlackAccount'
  has_one :fact_checking_channel
  has_one :status_comment, -> { where(subtype: 'status comment') }, as: :commentable, class_name: 'Comment'

  has_many :data_sets
  has_many :sheriffs,              foreign_key: :sheriff_id,   class_name: 'DataSet'
  has_many :edit_story_types,      foreign_key: :editor_id,    class_name: 'StoryType'
  has_many :edit_article_types,    foreign_key: :editor_id,    class_name: 'ArticleType'
  has_many :dev_story_types,       foreign_key: :developer_id, class_name: 'StoryType'
  has_many :dev_article_types,     foreign_key: :developer_id, class_name: 'ArticleType'
  has_many :submitters,            foreign_key: :submitter_id, class_name: 'PostExportReport'
  has_many :created_scrape_tasks,  foreign_key: :creator_id,   class_name: 'ScrapeTask'
  has_many :assigned_scrape_tasks, foreign_key: :scraper_id,   class_name: 'ScrapeTask'
  has_many :production_removals
  has_many :comments, foreign_key: :commentator_id
  has_many :assigned_scrape_tasks, class_name: 'ScrapeTask', foreign_key: :scraper_id
  has_many :created_scrape_tasks,  class_name: 'ScrapeTask', foreign_key: :creator_id
  has_many :cards, class_name: 'AccountCard'

  has_and_belongs_to_many :roles

  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: 'Invalid' }
  validates_uniqueness_of :email, case_sensitive: true
  validates :password, length: { minimum: 6, maximum: 20 }, if: -> { password.present? }

  def generate_token(column)
    loop do
      self[column] = SecureRandom.urlsafe_base64
      break unless Account.exists?(column => self[column])
    end
  end

  def name
    "#{first_name} #{last_name}"
  end

  def slack_identifier
    slack&.identifier
  end
end
