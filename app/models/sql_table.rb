# frozen_string_literal: true

class SqlTable < ApplicationRecord
  belongs_to :schema

  has_many :table_locations, dependent: :destroy

  scope :existing, -> { where(presence: true) }
end
