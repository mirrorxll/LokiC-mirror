# frozen_string_literal: true

class Priority < ApplicationRecord
  has_many :work_requests
end
