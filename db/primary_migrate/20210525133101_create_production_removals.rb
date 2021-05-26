# frozen_string_literal: true

class CreateProductionRemovals < ActiveRecord::Migration[6.0]
  def change
    create_table :production_removals do |t|
      t.belongs_to :iteration
      t.belongs_to :account

      t.string  :reasons, limit: 2000
      t.boolean :status, default: false
      t.timestamps
    end
  end
end
