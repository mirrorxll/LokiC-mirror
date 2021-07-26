# frozen_string_literal: true

class RenameColumnInChangeHistory < ActiveRecord::Migration[6.0]
  def change
    rename_column :change_history, :history_event, :event
  end
end
