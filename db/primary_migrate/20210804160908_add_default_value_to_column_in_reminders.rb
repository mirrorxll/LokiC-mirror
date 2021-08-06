# frozen_string_literal: true

class AddDefaultValueToColumnInReminders < ActiveRecord::Migration[6.0]
  def change
    change_column_default :reminders, :updates_confirmed, false
  end
end
