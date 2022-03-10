# frozen_string_literal: true

class OpportunityPublication < ApplicationRecord
  self.table_name = 'opportunities_publications'

  belongs_to :opportunity, optional: true
  belongs_to :publication, optional: true
end
