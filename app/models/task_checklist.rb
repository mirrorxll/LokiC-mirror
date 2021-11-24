# frozen_string_literal: true

class TaskChecklist < ApplicationRecord # :nodoc:
  validates :description, length: { maximum: 255 }

  after_create do
    task.assignment_to.each { |assignment| TaskChecklistAssignment.create!(account: assignment, checklist: self) }
  end

  belongs_to :task
end
