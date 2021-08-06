# frozen_string_literal: true

class RemoveColumnsFromAlerts < ActiveRecord::Migration[6.0]
  def change
    remove_columns :alerts, :subtype_id, :note_id
  end
end
