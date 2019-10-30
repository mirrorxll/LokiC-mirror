# frozen_string_literal: true

class PhotoBucket < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :stories, join_table: 'stories__photo_buckets'
end
