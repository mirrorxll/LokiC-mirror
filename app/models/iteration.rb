# frozen_string_literal: true

class Iteration < ApplicationRecord # :nodoc:
  serialize :story_sample_args, Hash
  serialize :schedule_counts, Hash

  after_create do
    if !name.eql?('Initial') && !story_type.status.name.in?(['canceled', 'blocked', 'on cron'])
      iteration_event = HistoryEvent.find_by(name: 'new iteration created')
      iteration_notes = "created a new iteration with id|name `#{id}|#{name}`"
      story_type.change_history.create(history_event: iteration_event, notes: iteration_notes)

      story_type.update(status: Status.find_by(name: 'in progress'), last_status_changed_at: DateTime.now)
      status_event = HistoryEvent.find_by(name: 'progress status changed')
      status_notes = "progress status changed to 'in progress'"
      story_type.change_history.create(history_event: status_event, notes: status_notes)
    end
  end

  belongs_to :story_type

  has_one :exported, dependent: :destroy, class_name: 'ExportedStoryType'

  has_many :samples
  has_many :auto_feedback_confirmations
  has_many :auto_feedback, through: :auto_feedback_confirmations
  has_many :production_removals

  has_and_belongs_to_many :statuses

  def show_samples
    samples.where(show: true)
  end

  def kill_population?
    reload.kill_population
  end

  def kill_creation?
    reload
    kill_story_samples || kill_creation
  end

  def kill_scheduling?
    reload.kill_schedule
  end

  def kill_export?
    reload.kill_export
  end
end
