# frozen_string_literal: true

class AddStatusToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    change_table :story_types do |t|
      t.belongs_to :status, after: :current_iteration_id
    end
  end
end
