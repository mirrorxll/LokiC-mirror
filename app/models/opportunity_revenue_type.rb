# frozen_string_literal: true

class OpportunityRevenueType < ApplicationRecord
  self.table_name = 'opportunities_revenue_types'

  belongs_to :opportunity
  belongs_to :revenue_type
end