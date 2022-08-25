# frozen_string_literal: true

class MultiTaskAgencyOpportunityRevenueType < ApplicationRecord # :nodoc:
  belongs_to :multi_task
  belongs_to :agency, class_name: 'MainAgency', optional: true
  belongs_to :opportunity, class_name: 'MainOpportunity', optional: true
  belongs_to :revenue_type, class_name: 'RevenueType', optional: true
end