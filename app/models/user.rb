# frozen_string_literal: true

class User < ApplicationRecord # :nodoc:
  enum account: %i[admin editor manager developer]

  has_one :story, foreign_key: :editor_id
  has_many :stories, foreign_key: :developer_id
  has_many :data_locations

  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
