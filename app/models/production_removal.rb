# frozen_string_literal: true

class ProductionRemoval < ApplicationRecord
  belongs_to :iteration
  belongs_to :account
end
