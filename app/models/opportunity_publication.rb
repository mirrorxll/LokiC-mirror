# frozen_string_literal: true

class OpportunityPublication < ApplicationRecord
  belongs_to :opportunity
  belongs_to :publication
end
