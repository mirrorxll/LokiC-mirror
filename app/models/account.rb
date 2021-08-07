# frozen_string_literal: true

class Account < ApplicationRecord # :nodoc:
  attr_accessor :type_ids, :slack_id # it needs for formtastic-activeadmin-form

  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_and_belongs_to_many :account_types

  has_one :slack, class_name: 'SlackAccount'
  has_one :fact_checking_channel

  has_many :data_sets
  has_many :sheriffs, foreign_key: :sheriff_id, class_name: 'DataSet'
  has_many :edit_story_types, foreign_key: :editor_id, class_name: 'StoryType'
  has_many :dev_story_types, foreign_key: :developer_id, class_name: 'StoryType'
  has_many :submitters, class_name: 'PostExportReport'
  has_many :production_removals
  has_many :scrape_tasks
  has_many :comments, foreign_key: :commentator_id

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
