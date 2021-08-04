# frozen_string_literal: true

class Task < ApplicationRecord # :nodoc:
  before_create do
    self.status = Status.find_by(name: 'not started')
  end

  validates :title, length: { maximum: 500 }
  validates :title, uniqueness: { scope: :creator }

  belongs_to :creator, class_name: 'Account'
  belongs_to :status, optional: true
  belongs_to :reminder_frequency, class_name: 'TaskReminderFrequency', optional: true

  has_many :tasks_assignments, class_name: 'TaskAssignment'
  has_many :assignment_to, through: :tasks_assignments, source: :account
  has_many :comments, -> { where(subtype: ['task comment','status comment']) }, as: :commentable, class_name: 'Comment'

  # has_one :status_comment, -> { where(subtype: 'status comment') }, as: :commentable, class_name: 'Comment'

  def status_comment
    comments.where(subtype: 'status comment').last
  end

  def gather_task_link
    return unless gather_task.present?

    "https://pipeline.locallabs.com/gather_tasks/#{gather_task}"
  end
end
