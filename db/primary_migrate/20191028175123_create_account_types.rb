# frozen_string_literal: true

class CreateAccountTypes < ActiveRecord::Migration[6.0]
  def change
    create_table :account_types do |t|
      t.string :name
      t.string :permissions, limit: 5_000
      t.timestamps
    end
  end
end
