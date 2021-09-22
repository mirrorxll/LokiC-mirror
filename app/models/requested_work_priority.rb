# frozen_string_literal: true

class RequestedWorkPriority < ApplicationRecord
  has_many :work_requests
end