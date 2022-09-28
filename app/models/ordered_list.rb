class OrderedList < ApplicationRecord
  belongs_to :account

  scope :first_grid, -> (branch_name) { where(branch_name: branch_name, position: 0).pluck(:grid_name).first }
end
