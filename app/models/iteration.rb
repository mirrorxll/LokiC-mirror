# frozen_string_literal: true

class Iteration < ApplicationRecord # :nodoc:
  serialize :story_sample_args, Hash
  serialize :schedule_counts, Hash

  before_create { statuses << Status.first }

  belongs_to :story_type

  has_and_belongs_to_many :statuses

  has_many :samples
  has_many :auto_feedback_confirmations
  has_many :auto_feedback, through: :auto_feedback_confirmations

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
