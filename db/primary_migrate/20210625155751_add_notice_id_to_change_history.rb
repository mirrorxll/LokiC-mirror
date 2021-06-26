# frozen_string_literal: true

class AddNoticeIdToChangeHistory < ActiveRecord::Migration[6.0]
  def change
    add_reference :change_history, :note, after: :history_event_id
  end
end
