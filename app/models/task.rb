# frozen_string_literal: true

class Task < ApplicationRecord # :nodoc:
  self.table_name = 'tasks'

  before_create do
    self.status = Status.find_by(name: 'created and in queue')
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

  has_one :main_task_assignment, -> { where(main: true) }, class_name: 'TaskAssignment'
  has_one :main_assignee, through: :main_task_assignment, source: :account

  has_many :task_assistants, -> { where(main: false, notification_to: false) }, class_name: 'TaskAssignment'
  has_many :assistants, through: :task_assistants, source: :account

  has_many :assignments_notifications, -> { where(notification_to: true) }, class_name: 'TaskAssignment'
  has_many :notification_to, through: :assignments_notifications, source: :account

  has_many :checklists, class_name: 'TaskChecklist'

  has_many :assignments, -> { where(notification_to: false) }, class_name: 'TaskAssignment'
  has_many :assignment_to, through: :assignments, source: :account

  has_many :comments, -> { where(commentable_type: 'Task') }, as: :commentable, class_name: 'Comment'
  has_many :subtasks, -> { where.not(status: Status.find_by(name: 'deleted')) }, foreign_key: :parent_task_id, class_name: 'Task'

  has_many :notes, class_name: 'TaskNote'

  has_many :agency_opportunity_revenue_types, class_name: 'TaskAgencyOpportunityRevenueType'

  scope :ongoing, -> { where(status: Status.multi_task_statuses) }

  has_and_belongs_to_many :scrape_tasks

  def agency_opportunity_hours
    tasks = subtasks_full_depth << self
    result = tasks.filter_map do |task|
      agency_opportunity_revenue_types = task.agency_opportunity_revenue_types
      next if agency_opportunity_revenue_types.empty?

      agency_opportunity_revenue_types.map do |row|
        {
          hours: task.assignments.sum(:hours) * row.percents / 100,
          agency: row.agency,
          opportunity: row.opportunity
        }
      end
    end.flatten
    result_uniq = result.uniq { |row| [row[:agency], row[:opportunity]] }

    result_uniq.map do |row|
      {
        hours: result.select { |res| res[:agency] == row[:agency] && res[:opportunity] == row[:opportunity] }.sum { |res| res[:hours] },
        agency: row[:agency],
        opportunity: row[:opportunity]
      }
    end
  end

  def subtasks_full_depth
    subtasks.flat_map do |subtask|
      subtask.subtasks_full_depth << subtask
    end
  end

  def assignment_to_or_creator?(account)
    account.in?(assignment_to) || account.eql?(creator) || account.in?(notification_to)
  end

  def creator?(account)
    account.eql?(creator)
  end

  def access_for?(account)
    return true if assignment_to_or_creator?(account)
    return false unless access

    subtasks.each { |subtask| return true if subtask.assignment_to_or_creator?(account) }
    parent&.subtasks&.each { |subtask| return true if subtask.assignment_to_or_creator?(account) }
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

  def current_assignment(account)
    assignments.find_by(account: account)
  end

  def done_by_all_assignments?
    assignments.find_by(done: false).nil?
  end

  def sum_hours
    format('%g', assignments.sum(:hours).to_s) + ' hours'
  end

  def subtask?
    !!parent
  end

  def note(account)
    notes.find_by(creator: account)
  end
end
old_status = Status.find_by(name: 'created and in queue')
new_status = Status.find_by(name: 'created and in queue')
[WorkRequest, FactoidRequest, Task, ScrapeTask, StoryType, FactoidType].each do |branch|
  branch.where(status: old_status).each do |i|
    i.update(status: new_status)
  end
end