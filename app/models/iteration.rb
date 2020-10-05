# frozen_string_literal: true

class Iteration < ApplicationRecord # :nodoc:
  serialize :story_sample_args, Hash
  serialize :schedule_counts, Hash
  serialize :export_data, Hash

  belongs_to :story_type

  has_and_belongs_to_many :statuses

  has_many :samples, dependent: :destroy
  has_many :auto_feedback_confirmations
  has_many :auto_feedback, through: :auto_feedback_confirmations

  before_create { statuses << Status.first }
end
