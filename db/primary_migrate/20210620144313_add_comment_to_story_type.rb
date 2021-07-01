# frozen_string_literal: true

class AddCommentToStoryType < ActiveRecord::Migration[6.0]
  def change
    add_column :story_types, :comment, :text, after: :name
  end
end
