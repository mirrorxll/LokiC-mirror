# frozen_string_literal: true

class DataSetCategory < ApplicationRecord
  has_many :data_sets, foreign_key: :category_id
end
