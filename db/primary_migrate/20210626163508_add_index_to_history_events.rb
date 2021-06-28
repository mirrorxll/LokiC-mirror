# frozen_string_literal: true

class AddIndexToHistoryEvents < ActiveRecord::Migration[6.0]
  def change
    add_index :history_events, :name, unique: true
  end
end
