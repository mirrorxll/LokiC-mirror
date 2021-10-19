# frozen_string_literal: true

class Task < ApplicationRecord # :nodoc:
  before_create do
    self.status = Status.find_by(name: 'not started')
  end

  validates :title, length: { maximum: 500 }
  validates :title, uniqueness: { scope: :creator }, case_sensitive: false

  belongs_to :creator, class_name: 'Account'
  belongs_to :status, optional: true
  belongs_to :reminder_frequency, class_name: 'TaskReminderFrequency', optional: true
  belongs_to :parent, class_name: 'Task', foreign_key: :parent_task_id, optional: true
  belongs_to :client, class_name: 'ClientsReport', foreign_key: :client_id, optional: true

  has_many :assignments, class_name: 'TaskAssignment'
  has_many :assignment_to, through: :assignments, source: :account

  has_many :comments, -> { where(subtype: ['task comment','status comment','status comment blocked', 'status comment canceled' ]) }, as: :commentable, class_name: 'Comment'
  has_many :subtasks, -> { where.not(status: Status.find_by(name: 'deleted')) }, foreign_key: :parent_task_id, class_name: 'Task'

  def status_comment
    ActionView::Base.full_sanitizer.sanitize(comments.where(subtype: 'status comment').last.body)
                    .gsub('Status changed to blocked.', '').gsub('Status changed to canceled.', '')
  end

  def gather_task_link
    return unless gather_task.present?

    "https://pipeline.locallabs.com/gather_tasks/#{gather_task}"
  end

  def assignment_to_or_creator?(account)
    account.in?(assignment_to) || account.eql?(creator)
  end

  def creator?(account)
    account.eql?(creator)
  end

  def title_with_id
    "##{id} #{title}"
  end

  def current_assignment(account)
    assignments.find_by(account: account)
  end

  def access?(account)
    return true if assignment_to_or_creator?(account)
    subtasks.each { |subtask| return true if subtask.assignment_to_or_creator?(account) }
    parent.subtasks.each { |subtask| return true if subtask.assignment_to_or_creator?(account) } if parent
    false
  end
end
