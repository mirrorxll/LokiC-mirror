# frozen_string_literal: true

class CreateAlertSubtypes < ActiveRecord::Migration[6.0]
  def change
    create_table :alert_subtypes do |t|
      t.string :name
      t.timestamps
    end
  end
end
