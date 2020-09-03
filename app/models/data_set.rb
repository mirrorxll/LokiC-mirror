# frozen_string_literal: true

class DataSet < ApplicationRecord # :nodoc:
  belongs_to :account
  belongs_to :evaluator, optional: true, class_name: 'Account'
  belongs_to :src_release_frequency, optional: true, class_name: 'Frequency'
  belongs_to :src_scrape_frequency, optional: true, class_name: 'Frequency'

  has_one :data_set_photo_bucket
  has_one :photo_bucket, through: :data_set_photo_bucket

  has_many :story_types

  has_many :client_tags, class_name: 'DataSetClientTag'
  has_many :clients, through: :client_tags
  has_many :tags, through: :client_tags

  def evaluated?
    evaluated
  end
end
