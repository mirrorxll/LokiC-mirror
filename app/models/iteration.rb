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

  has_one :editor_post_export_report,  -> { where(report_type: 'editor') },  class_name: 'PostExportReport'
  has_one :manager_post_export_report, -> { where(report_type: 'manager') }, class_name: 'PostExportReport'

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
