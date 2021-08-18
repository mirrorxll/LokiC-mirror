# frozen_string_literal: true

class RenameSamplesToStories < ActiveRecord::Migration[6.0]
  def change
    rename_table :samples, :stories
  end
end
