class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary }

  def record_to_change_history(story_type, event, note)
    note_to_md5 = Digest::MD5.hexdigest(note)
    text = Text.find_or_create_by!(md5hash: note_to_md5) { |t| t.text = note }
    history_event = HistoryEvent.find_or_create_by!(name: event)

    story_type.change_history.create!(history_event: history_event, note: text)
  end
end
