# frozen_string_literal: true

class InvoiceType < ApplicationRecord
  has_many :work_requests
end
