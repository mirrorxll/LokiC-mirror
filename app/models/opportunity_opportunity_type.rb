# frozen_string_literal: true

class OpportunityOpportunityType < ApplicationRecord
  self.table_name = 'opportunities_opportunity_types'

  belongs_to :opportunity,      optional: true
  belongs_to :opportunity_type, optional: true
end
