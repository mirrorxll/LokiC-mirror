# frozen_string_literal: true

class RenameHiddenToHiddenForStoryTypeInClients < ActiveRecord::Migration[6.0]
  def change
    rename_column :clients, :hidden, :hidden_for_story_type
  end
end
