# frozen_string_literal: true

class AddDeadlineToStoryTypes < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :deadline, :date, after: :comment
  end
end
