# frozen_string_literal: true

class Branch < ApplicationRecord
  has_many :access_levels
  has_many :account_cards
end
