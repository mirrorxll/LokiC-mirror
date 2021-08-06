# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  attr_accessor :current_account

  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary }

  def record_to_change_history(model, event, note, account)
    model.change_history.create!(event: event, note: note, account: account)
  end
end
