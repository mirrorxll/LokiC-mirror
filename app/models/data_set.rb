# frozen_string_literal: true

class DataSet < ApplicationRecord # :nodoc:
  belongs_to :account

  has_one :data_set_photo_bucket
  has_one :photo_bucket, through: :data_set_photo_bucket

  has_and_belongs_to_many :sheriffs, class_name: 'Account', join_table: 'data_sets_sheriffs'

  has_many :story_types
  has_many :client_tags, class_name: 'DataSetClientTag'
  has_many :clients, through: :client_tags
  has_many :tags, through: :client_tags
end
