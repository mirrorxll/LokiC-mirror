# frozen_string_literal: true

class AddHistoryEventToChangeHistory < ActiveRecord::Migration[6.0]
  def change
    add_column :change_history, :history_event, :string, after: :history_id
  end
end
