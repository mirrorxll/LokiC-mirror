# frozen_string_literal: true

class RemoveColumnsFromChangeHistory < ActiveRecord::Migration[6.0]
  def change
    remove_columns :change_history, :history_event_id, :note_id
  end
end
