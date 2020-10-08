# frozen_string_literal: true

class FactCheckingDoc < ApplicationRecord
  before_save :drop_negative_margins

  belongs_to :story_type

  has_many :reviewers_feedback
  has_many :editors_feedback

  def approval_editors
    editors_feedback.where(approvable: true).uniq(&:editor).map(&:editor)
  end

  private

  def drop_negative_margins
    body.gsub!(/margin[-a-z:]+[^;]*?(?:-\d)[^;]*?;/, '')
  end
end
