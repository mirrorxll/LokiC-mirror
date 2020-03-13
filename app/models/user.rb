# frozen_string_literal: true

class User < ApplicationRecord # :nodoc:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum account: %i[admin editor manager developer]

  has_many :eval_data_sets,   foreign_key: :evaluator_id,  class_name: 'DataLocation'
  has_many :edit_story_type,  foreign_key: :editor_id,     class_name: 'StoryType'
  has_many :dev_story_types,  foreign_key: :developer_id,  class_name: 'StoryType'
  has_many :data_locations

  belongs_to :account_type

  def username
    "#{first_name} #{last_name}"
  end
end
