# frozen_string_literal: true

class ChangePublishedAtInStories < ActiveRecord::Migration[6.0]
  def change
    change_column :stories, :published_at, :datetime
  end
end
