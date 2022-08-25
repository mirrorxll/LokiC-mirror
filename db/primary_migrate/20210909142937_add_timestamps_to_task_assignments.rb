# frozen_string_literal: true

class AddTimestampsToTaskAssignments < ActiveRecord::Migration[6.0]
  def change
    add_timestamps :task_assignments, null: false, default: Time.zone.now

    MultiTaskAssignment.all.each do |task_assignment|
      task_assignment.update!(created_at: task_assignment.task[:created_at].to_s,
                              updated_at: task_assignment.task[:created_at].to_s)
    end
  end
end
