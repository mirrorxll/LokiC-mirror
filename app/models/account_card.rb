# frozen_string_literal: true

class AccountCard < ApplicationRecord
  belongs_to :account
  belongs_to :branch
  belongs_to :access_level
end
