class ListOrder < ApplicationRecord
  belongs_to :account

  scope :first_grid, -> (branch_name) { where(branch: branch_name, position: 1).pluck(:grid_name).first }
end
