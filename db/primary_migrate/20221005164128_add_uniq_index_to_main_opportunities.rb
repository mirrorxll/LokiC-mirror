# frozen_string_literal: true

class AddUniqIndexToMainOpportunities < ActiveRecord::Migration[6.0]
  def change
    add_index :main_opportunities, :name, unique: true
  end
end
