# frozen_string_literal: true

class Account < ApplicationRecord # :nodoc:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :account_type

  has_one :slack_account

  has_many :eval_data_sets,   foreign_key: :evaluator_id, class_name: 'DataSet'
  has_many :edit_story_types, foreign_key: :editor_id,    class_name: 'StoryType'
  has_many :dev_story_types,  foreign_key: :developer_id, class_name: 'StoryType'
  has_many :data_sets

  def name
    "#{first_name} #{last_name}"
  end

  def permissions
    account_type.permissions
  end
end
