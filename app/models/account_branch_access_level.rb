# frozen_string_literal: true

class AccountBranchAccessLevel < ApplicationRecord
  self.table_name = 'accounts_branches_access_levels'

  belongs_to :account
  belongs_to :branch
  belongs_to :access_level
end
