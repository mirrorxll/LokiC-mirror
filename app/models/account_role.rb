# frozen_string_literal: true

class AccountRole < ApplicationRecord
  has_and_belongs_to_many :accounts
end
