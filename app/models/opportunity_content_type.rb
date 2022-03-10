# frozen_string_literal: true

class OpportunityContentType < ApplicationRecord
  self.table_name = 'opportunities_content_types'

  belongs_to :opportunity,  optional: true
  belongs_to :content_type, optional: true
end
