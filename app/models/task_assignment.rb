# frozen_string_literal: true

class TaskAssignment < ApplicationRecord # :nodoc:
  before_create  { TaskReceipt.create!(task: self.task, assignment: self.account) }
  before_destroy { TaskReceipt.find_by(task: self.task, assignment: self.account)&.destroy }

  belongs_to :task
  belongs_to :account
end
