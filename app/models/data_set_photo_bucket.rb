# frozen_string_literal: true

class DataSetPhotoBucket < ApplicationRecord # :nodoc:
  belongs_to :data_set
  belongs_to :photo_bucket, optional: true
end
