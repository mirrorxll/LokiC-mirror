# frozen_string_literal: true

class MainOpportunity < ApplicationRecord
  belongs_to :agency, class_name: 'MainAgency', optional: true

  has_many :main_opportunity_revenue_types
  has_many :revenue_types, through: :main_opportunity_revenue_types
end
