# frozen_string_literal: true

class ArticleTypeIteration < ApplicationRecord # :nodoc:
  serialize :sample_args, Hash
  serialize :schedule_counts, Hash

  after_create do
    if !name.eql?('Initial') && !story_type.status.name.in?(['canceled', 'blocked', 'on cron'])
      story_type.update!(status: Status.find_by(name: 'in progress'), current_account: current_account)
    end
  end

  belongs_to :article_type

  has_many :articles
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
    kill_samples || kill_creation
  end

  def kill_scheduling?
    reload.kill_schedule
  end

  def kill_export?
    reload.kill_export
  end
end
