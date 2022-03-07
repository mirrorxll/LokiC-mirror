# frozen_string_literal: true

class CreateOpportunities < ActiveRecord::Migration[6.0]
  def change
    create_table :opportunities, id: false do |t|
      t.string   :id, limit: 36, primary_key: true
      t.string   :name
      t.datetime :archived_at, index: true
      t.string   :agency_id, index: true
      t.timestamps
    end
  end
end
