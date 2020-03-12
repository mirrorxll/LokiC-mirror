# frozen_string_literal: true

class User < ApplicationRecord # :nodoc:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum account: %i[admin editor manager developer]

  has_one :story, foreign_key: :editor_id
  has_many :stories, foreign_key: :developer_id
  has_many :data_locations

  def username
    "#{first_name} #{last_name}"
  end
end
