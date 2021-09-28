# frozen_string_literal: true

class AddHiddenForWorkRequestToClients < ActiveRecord::Migration[6.0]
  def change
    add_column :clients, :hidden_for_work_request, :boolean, default: true, after: :hidden_for_story_type
  end
end
