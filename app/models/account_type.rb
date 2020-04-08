# frozen_string_literal: true

class AccountType < ApplicationRecord # :nodoc:
  serialize :permissions, JSON

  has_many :accounts
end
