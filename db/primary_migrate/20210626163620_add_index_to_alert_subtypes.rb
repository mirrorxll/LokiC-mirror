# frozen_string_literal: true

class AddIndexToAlertSubtypes < ActiveRecord::Migration[6.0]
  def change
    add_index :alert_subtypes, :name, unique: true
  end
end
