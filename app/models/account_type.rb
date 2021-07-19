# frozen_string_literal: true

class AccountType < ApplicationRecord # :nodoc:
  has_and_belongs_to_many :accounts
end
