# frozen_string_literal: true

class AccountType < ApplicationRecord # :nodoc:
  has_many :users
end
