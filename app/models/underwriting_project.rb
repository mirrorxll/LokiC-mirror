# frozen_string_literal: true

class UnderwritingProject < ApplicationRecord
  has_many :work_requests
end
