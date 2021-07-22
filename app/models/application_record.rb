# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary }

  def record_to_change_history(story_type, event, message)
    story_type.change_history.create!(history_event: event, note: message)
  end
end
