# frozen_string_literal: true

class AddPurgeScheduleToStoryTypeIterations < ActiveRecord::Migration[6.0]
  def change
    add_column :story_type_iterations, :purge_schedule, :boolean, after: :schedule_counts
  end
end
