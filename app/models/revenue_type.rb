# frozen_string_literal: true

class RevenueType < ApplicationRecord
  has_and_belongs_to_many :work_requests

  validates_uniqueness_of :name, case_sensitive: true
end
