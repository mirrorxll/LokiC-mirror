# frozen_string_literal: true

class AddUniqIndexToOrderedLists < ActiveRecord::Migration[6.0]
  def change
    add_index :ordered_lists, %i[account_id branch_name grid_name], unique: true, name: :uniq_ordered_list
  end
end
