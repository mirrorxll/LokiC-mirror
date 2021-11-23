# frozen_string_literal: true

class EditorsFeedback < ApplicationRecord
  default_scope { order(created_at: :desc) }
  serialize :approval, Hash

  belongs_to :fact_checking_doc
  belongs_to :editor, class_name: 'Account'

  has_rich_text :body
end
