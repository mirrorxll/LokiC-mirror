# frozen_string_literal: true

class Text < ApplicationRecord
  has_many :alerts,         foreign_key: :message_id
  has_many :change_history, foreign_key: :note_id
end
