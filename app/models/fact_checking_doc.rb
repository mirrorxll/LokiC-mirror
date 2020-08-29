# frozen_string_literal: true

class FactCheckingDoc < ApplicationRecord
  belongs_to :story_type

  has_many :reviewers_feedback
  has_many :editors_feedback
end
