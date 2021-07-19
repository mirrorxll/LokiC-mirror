# frozen_string_literal: true

class Iteration < ApplicationRecord # :nodoc:
  serialize :story_sample_args, Hash
  serialize :schedule_counts, Hash

  after_create do
    if !name.eql?('Initial') && !story_type.status.name.in?(['canceled', 'blocked', 'on cron'])
      iteration_note = "created a new iteration with id|name `#{id}|#{name}`"
      record_to_change_history(story_type, 'new iteration created', iteration_note)

      story_type.update(status: Status.find_by(name: 'in progress'))

      status_note = "progress status changed to 'in progress'"
      record_to_change_history(story_type, 'progress status changed', status_note)
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
