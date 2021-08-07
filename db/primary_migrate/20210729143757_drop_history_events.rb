# frozen_string_literal: true

class DropHistoryEvents < ActiveRecord::Migration[6.0]
  def change
    drop_table :history_events do |t|
      t.string :name
      t.timestamps
    end
  end
end
