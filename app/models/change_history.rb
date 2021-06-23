# frozen_string_literal: true

class ChangeHistory < ApplicationRecord
  belongs_to :historyable, polymorphic: true
  belongs_to :history_event, optional: true
end
