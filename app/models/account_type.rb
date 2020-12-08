# frozen_string_literal: true

class AccountType < ApplicationRecord # :nodoc:
  serialize :permissions, JSON

  has_and_belongs_to_many :accounts
end
