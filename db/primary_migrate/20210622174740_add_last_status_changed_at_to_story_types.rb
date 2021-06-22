# frozen_string_literal: true

class AddLastStatusChangedAtToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :last_status_changed_at, :datetime, after: :name
  end
end
