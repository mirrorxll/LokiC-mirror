# frozen_string_literal: true

class DataSetClientTag < ApplicationRecord # :nodoc:
  belongs_to :data_set
  belongs_to :client, optional: true
  belongs_to :tag,    optional: true
end
