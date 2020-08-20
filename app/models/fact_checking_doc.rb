# frozen_string_literal: true

class FactCheckingDoc < ApplicationRecord
  belongs_to :story_type

  has_one :reviewers_feedback
  has_one :editors_feedback

  before_create do
    build_reviewers_feedback
    build_editors_feedback
  end
end
