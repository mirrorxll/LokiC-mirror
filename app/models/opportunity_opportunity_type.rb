# frozen_string_literal: true

class OpportunityOpportunityType < ApplicationRecord
  belongs_to :opportunity
  belongs_to :opportunity_type
end
