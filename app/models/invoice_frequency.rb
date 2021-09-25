# frozen_string_literal: true

class InvoiceFrequency < ApplicationRecord
  has_many :work_requests
end
