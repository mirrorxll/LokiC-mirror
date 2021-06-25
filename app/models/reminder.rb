# frozen_string_literal: true

class Reminder < ApplicationRecord
  after_update do
    event = HistoryEvent.find_by(name: 'reminder turned off')
    notes = "reminders turned off until #{turn_off_until}; #{reasons}"
    story_type.change_history.create(history_event: event, notes: notes)
  end

  belongs_to :story_type
end
