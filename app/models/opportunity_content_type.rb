# frozen_string_literal: true

class OpportunityContentType < ApplicationRecord
  belongs_to :opportunity
  belongs_to :content_type
end
