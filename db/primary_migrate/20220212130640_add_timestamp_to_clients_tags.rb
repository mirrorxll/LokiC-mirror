# frozen_string_literal: true

class AddTimestampToClientsTags < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :clients_tags, null: true

    ClientTag.update_all(created_at: DateTime.now, updated_at: DateTime.now)

    change_column_null :clients_tags, :created_at, false
    change_column_null :clients_tags, :updated_at, false
  end
end
