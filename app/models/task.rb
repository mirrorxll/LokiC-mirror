# frozen_string_literal: true

class Task < ApplicationRecord # :nodoc:
  before_create do
    self.status = Status.find_by(name: 'not started')
  end

  validates :title, length: { maximum: 1000 }

  belongs_to :creator, class_name: 'Account'
  belongs_to :status, optional: true
  belongs_to :reminder_frequency, class_name: 'TaskReminderFrequency', optional: true

  has_many :tasks_assignments, class_name: 'TaskAssignment'
  has_many :assignment_to, through: :tasks_assignments, source: :account

end
