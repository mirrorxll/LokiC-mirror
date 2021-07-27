# frozen_string_literal: true

class Reminder < ApplicationRecord
  before_update do
    if turn_off_until_changed?
      message = "reminders turned off until #{turn_off_until}; #{reasons}"
      record_to_change_history(story_type, 'reminder turned off', message, current_account)
    end
  end

  belongs_to :story_type
end
