# frozen_string_literal: true

class AddLastStatusChangeToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    change_table :story_types do |t|
      t.datetime :last_status_change, after: :last_export
      t.boolean  :updates, after: :last_status_change
      t.date     :blocked_until, after: :updates
    end
  end
end
