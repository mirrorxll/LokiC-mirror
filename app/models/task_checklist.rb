# frozen_string_literal: true

class TaskChecklist < ApplicationRecord # :nodoc:
  validates :description, length: { maximum: 255 }

  belongs_to :task

  after_create do
    task.assignment_to.each { |assignment| TaskChecklistAssignment.create!(task: task, account: assignment, checklist: self) }
  end
end
