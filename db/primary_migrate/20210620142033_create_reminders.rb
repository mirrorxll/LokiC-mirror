# frozen_string_literal: true

class CreateReminders < ActiveRecord::Migration[6.0]
  def change
    create_table :reminders do |t|
      t.belongs_to :story_type

      t.boolean  :has_updates, default: false, after: :last_status_change
      t.boolean  :updates_confirmed, after: :has_updates
      t.date     :turn_off_until, after: :updates_confirmed
      t.string   :reasons, limit: 1000
      t.timestamps
    end
  end
end
