# frozen_string_literal: true

class MainOpportunityRevenueType < ApplicationRecord
  self.table_name = 'main_opportunities_revenue_types'

  belongs_to :main_opportunity, optional: true
  belongs_to :revenue_type,     optional: true
end