# frozen_string_literal: true

class FactCheckingChannel < ApplicationRecord
  belongs_to :account, optional: true
end
