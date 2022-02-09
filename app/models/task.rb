# frozen_string_literal: true

class Task < ApplicationRecord # :nodoc:
  before_create do
    self.status = Status.find_by(name: 'not started')
  end

  before_save do
    regexp = '<p data-f-id="pbf" style="text-align: center; font-size: 14px; margin-top: 30px; opacity: 0.65; '\
             'font-family: sans-serif;">Powered by <a href="https://www.froala.com/wysiwyg-editor?pb=1" '\
             'title="Froala Editor">Froala Editor</a></p>'

    self.description = description&.gsub(/#{Regexp.escape(regexp)}/, '')
  end

  validates :title, length: { maximum: 500 }
  validates :title, uniqueness: { scope: :creator }, case_sensitive: false

  belongs_to :creator, class_name: 'Account'
  belongs_to :status, optional: true
  belongs_to :reminder_frequency, class_name: 'TaskReminderFrequency', optional: true
  belongs_to :parent, class_name: 'Task', foreign_key: :parent_task_id, optional: true
  belongs_to :client, class_name: 'ClientsReport', foreign_key: :client_id, optional: true
  belongs_to :work_request, optional: true

  has_one :team_work, class_name: 'TaskTeamWork'
  has_one :last_comment, -> { order created_at: :desc }, as: :commentable, class_name: 'Comment'

  has_many :checklists, class_name: 'TaskChecklist'
  has_many :checklists_assignments, class_name: 'TaskChecklistAssignment'

  has_many :assignments, class_name: 'TaskAssignment'
  has_many :assignment_to, through: :assignments, source: :account

  has_many :comments, -> { where(commentable_type: 'Task') }, as: :commentable, class_name: 'Comment'
  has_many :subtasks, -> { where.not(status: Status.find_by(name: 'deleted')) }, foreign_key: :parent_task_id, class_name: 'Task'

  has_many :notes, class_name: 'TaskNote'

  has_and_belongs_to_many :scrape_tasks

  def assignment_to_or_creator?(account)
    account.in?(assignment_to) || account.eql?(creator)
  end

  def creator?(account)
    account.eql?(creator)
  end

  def access_for?(account)
    return true if assignment_to_or_creator?(account)
    return false unless access

    subtasks.each { |subtask| return true if subtask.assignment_to_or_creator?(account) }
    parent.subtasks.each { |subtask| return true if subtask.assignment_to_or_creator?(account) } if parent
    false
  end

  def has_checklists?
    checklists.exists?
  end

  def status_comment
    ActionView::Base.full_sanitizer.sanitize(comments.where(subtype: 'status comment').last.body)
                    .gsub('Status changed to blocked.', '').gsub('Status changed to canceled.', '')
  end

  def gather_task_link
    return unless gather_task.present?

    "https://pipeline.locallabs.com/gather_tasks/#{gather_task}"
  end

  def title_with_id
    "##{id} #{title}"
  end

  def checklists_assignments_for(account)
    checklists_assignments.where(account: account)
  end

  def current_assignment(account)
    assignments.find_by(account: account)
  end

  def done_by_all_assignments?
    assignments.find_by(done: false).nil?
  end

  def sum_hours
    sprintf('%g', assignments.sum(:hours).to_s) + ' hours'
  end

  def subtask?
    !!parent
  end

  def note(account)
    notes.find_by(creator: account)
  end
end
