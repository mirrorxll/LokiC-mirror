# frozen_string_literal: true

class CreateMainAgencies < ActiveRecord::Migration[6.0]
  def change
    create_table :main_agencies do |t|
      t.string  :pipeline_id, limit: 36
      t.string  :name
      t.timestamps
    end
  end
end
