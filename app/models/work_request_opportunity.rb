# frozen_string_literal: true

class WorkRequestOpportunity < ApplicationRecord
  belongs_to :work_request
  belongs_to :main_agency
  belongs_to :main_opportunity
end
