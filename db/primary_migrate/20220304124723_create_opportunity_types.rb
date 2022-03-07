# frozen_string_literal: true

class CreateOpportunityTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :opportunity_types, id: false do |t|
      t.string :id, limit: 36, primary_key: true
      t.string :name
      t.timestamps
    end
  end
end
