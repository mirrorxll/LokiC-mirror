# frozen_string_literal: true

class RenameTextsToNotes < ActiveRecord::Migration[6.0]
  def change
    rename_table :texts, :notes
    rename_column :notes, :text, :note
    rename_column :alerts, :message_id, :note_id
  end
end
