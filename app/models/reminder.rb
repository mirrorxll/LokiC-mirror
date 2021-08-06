# frozen_string_literal: true

class Reminder < ApplicationRecord
  before_update do
    changes = {}
    changes['has updates'] = "#{has_updates_change.first} -> #{has_updates}" if has_updates_changed?
    changes['updates_confirmed'] = "#{updates_confirmed_change.first} -> #{updates_confirmed}" if updates_confirmed_changed?
    changes['reminder turned off'] = "until #{turn_off_until}; #{reasons}" if turn_off_until_changed?

    changes.each { |ev, ch| record_to_change_history(story_type, ev, ch, current_account) }
  end

  belongs_to :story_type
end
