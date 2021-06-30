# frozen_string_literal: true

class Reminder < ApplicationRecord
  after_update do
    note = "reminders turned off until #{turn_off_until}; #{reasons}"
    record_to_change_history(story_type, 'reminder turned off', note)
  end

  belongs_to :story_type
end
