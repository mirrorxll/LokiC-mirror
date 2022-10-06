# frozen_string_literal: true

class MainAgency < ApplicationRecord
  has_many :opportunities, class_name: 'MainOpportunity'

  validates_uniqueness_of :name, case_sensitive: true
end
