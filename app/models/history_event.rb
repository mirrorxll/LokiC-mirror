# frozen_string_literal: true

class HistoryEvent < ApplicationRecord
  has_many :change_history
end
