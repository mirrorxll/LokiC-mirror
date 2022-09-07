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
  has_many :edit_factoid_types,    foreign_key: :editor_id,    class_name: 'FactoidType'
  has_many :dev_story_types,       foreign_key: :developer_id, class_name: 'StoryType'
  has_many :dev_factoid_types,     foreign_key: :developer_id, class_name: 'FactoidType'
  has_many :submitters,            foreign_key: :submitter_id, class_name: 'PostExportReport'
  has_many :assigned_scrape_tasks, foreign_key: :scraper_id,   class_name: 'ScrapeTask'
  has_many :production_removals
  has_many :comments, foreign_key: :commentator_id
  has_many :assigned_scrape_tasks, class_name: 'ScrapeTask', foreign_key: :scraper_id
  has_many :created_scrape_tasks,  class_name: 'ScrapeTask', foreign_key: :creator_id
  has_many :cards, class_name: 'AccountCard'
  has_many :exception_records

  has_and_belongs_to_many :roles, class_name: 'AccountRole'

  scope :get_accounts, ->(account_type) { joins(:roles).where('account_roles.name': account_type) }

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

  def role_names
    roles.map(&:name)
  end

  def manager?
    role_names.include?('Manager')
  end

  def content_manager?
    role_names.include?('Content Manager')
  end

  def content_fcd_checker?
    role_names.include?('Content FCD Checker')
  end

  def content_data_cleaner?
    role_names.include?('Content Data Cleaner')
  end

  def content_developer?
    role_names.include?('Content Developer')
  end

  def scrape_manager?
    role_names.include?('Scrape Manager')
  end

  def scrape_data_reviewer?
    role_names.include?('Scrape Data Reviewer')
  end

  def scrape_developer?
    role_names.include?('Scrape Developer')
  end

  def client?
    role_names.include?('Client')
  end

  def guest?
    role_names.include?('Guest')
  end

  def branch_names
    cards.where(enabled: true).includes(:branch).map { |card| card.branch.name }
  end
end
