# frozen_string_literal: true

class DataSetCategory < ApplicationRecord
  has_many :data_sets
end
