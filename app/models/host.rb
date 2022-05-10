# frozen_string_literal: true

class Host < ApplicationRecord
  has_many :schemas
  has_many :table_locations
end
