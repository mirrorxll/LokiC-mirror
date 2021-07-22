# frozen_string_literal: true

class AddNoteToChangeHistory < ActiveRecord::Migration[6.0]
  def change
    add_column :change_history, :body, :string, limit: 2000, after: :history_event
  end
end
