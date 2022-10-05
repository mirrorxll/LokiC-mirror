# frozen_string_literal: true

class AddUniqIndexToRevenueTypes < ActiveRecord::Migration[6.0]
  def change
    add_index :revenue_types, :name, unique: true
  end
end
