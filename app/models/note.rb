# frozen_string_literal: true

class Note < ApplicationRecord
  has_many :alerts,         foreign_key: :note_id
  has_many :change_history, foreign_key: :note_id
end
