# frozen_string_literal: true

class CreateMainOpportunities < ActiveRecord::Migration[6.0]
  def change
    create_table :main_opportunities do |t|
      t.string       :pipeline_id, limit: 36
      t.string       :name
      t.belongs_to   :main_agency
      t.timestamps
    end
  end
end
