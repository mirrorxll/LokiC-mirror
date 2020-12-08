# frozen_string_literal: true

class Account < ApplicationRecord # :nodoc:
  attr_accessor :type_ids, :slack_id # it needs for formtastic-activeadmin-form

  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  has_and_belongs_to_many :account_types

  has_one :slack, class_name: 'SlackAccount'
  has_one :fc_channel

  has_many :eval_data_sets,   foreign_key: :evaluator_id, class_name: 'DataSet'
  has_many :edit_story_types, foreign_key: :editor_id,    class_name: 'StoryType'
  has_many :dev_story_types,  foreign_key: :developer_id, class_name: 'StoryType'
  has_many :data_sets

  def name
    "#{first_name} #{last_name}"
  end

  def types
    account_types.map(&:name)
  end
end
