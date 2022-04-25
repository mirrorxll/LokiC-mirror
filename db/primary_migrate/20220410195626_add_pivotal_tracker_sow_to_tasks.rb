# frozen_string_literal: true

class AddPivotalTrackerSowToTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :tasks, :pivotal_tracker_name, :string, after: :access
    add_column :tasks, :pivotal_tracker_url, :string, after: :pivotal_tracker_name
    add_column :tasks, :sow, :string, after: :pivotal_tracker_url
  end
end
