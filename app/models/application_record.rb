# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary }

  def record_to_change_history(story_type, event, message)
    note_to_md5 = Digest::MD5.hexdigest(message)
    note = Note.find_or_create_by!(md5hash: note_to_md5) { |t| t.note = message }
    history_event = HistoryEvent.find_or_create_by!(name: event)

    story_type.change_history.create!(history_event: history_event, note: note)
  end
end
