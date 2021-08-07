# frozen_string_literal: true

class DropAlertSubtypes < ActiveRecord::Migration[6.0]
  def change
    drop_table :alert_subtypes do |t|
      t.string :name
      t.timestamps
    end
  end
end
