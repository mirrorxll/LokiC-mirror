# frozen_string_literal: true

class EditorsFeedback < ApplicationRecord
  default_scope { order(created_at: :desc) }

  belongs_to :fact_checking_doc
  belongs_to :editor, class_name: 'Account'
end
