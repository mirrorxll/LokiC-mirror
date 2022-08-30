# frozen_string_literal: true

class Schema < ApplicationRecord
  belongs_to :host

  has_many :sql_tables, dependent: :destroy
  has_many :table_locations, dependent: :destroy

  scope :existing, -> { where(presence: true) }
end
