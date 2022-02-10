# frozen_string_literal: true

class StoryTypeIteration < ApplicationRecord # :nodoc:
  serialize :sample_args, Hash
  serialize :schedule_counts, Hash

  after_create do
    if !name.eql?('Initial') && !story_type.status.name.in?(['canceled', 'blocked', 'on cron'])
      story_type.update!(status: Status.find_by(name: 'in progress'), current_account: current_account)

      record_to_change_history(story_type, 'new iteration created', "`#{id}|#{name}`", current_account)
    end
  end

  belongs_to :story_type

  has_one :exported, dependent: :destroy, class_name: 'ExportedStoryType', foreign_key: :iteration_id

  has_many :auto_feedback_confirmations
  has_many :auto_feedback, through: :auto_feedback_confirmations
  has_many :stories
  has_many :production_removals, foreign_key: :iteration_id

  belongs_to :status, optional: true

  def show_samples
    stories.where(show: true)
  end

  def kill_population?
    reload.kill_population
  end

  def kill_creation?
    reload
    kill_samples || kill_creation
  end

  def kill_scheduling?
    reload.kill_schedule
  end

  def kill_export?
    reload.kill_export
  end
end
