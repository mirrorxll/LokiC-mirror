# frozen_string_literal: true

class CreateAgencies < ActiveRecord::Migration[6.0]
  def change
    create_table :agencies, id: false do |t|
      t.string  :id, limit: 36, primary_key: true
      t.string  :name
      t.string  :partner
      t.timestamps
    end
  end
end
