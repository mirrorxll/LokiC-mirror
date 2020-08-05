# frozen_string_literal: true

class FactCheckingDoc < ApplicationRecord
  belongs_to :story_type

  has_one :editor_feedback

  before_create { build_editor_feedback }
end
