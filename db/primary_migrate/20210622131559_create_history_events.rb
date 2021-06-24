# frozen_string_literal: true

class CreateHistoryEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :history_events do |t|
      t.string :name
      t.timestamps
    end
  end
end
