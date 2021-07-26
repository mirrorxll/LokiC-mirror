# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary }

  def record_to_change_history(model, event, message)
    model.change_history.create!(event: event, body: message)
  end
end
