# frozen_string_literal: true

class CreateRevenueTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :revenue_types do |t|
      t.string :name
      t.timestamps
    end
  end
end
