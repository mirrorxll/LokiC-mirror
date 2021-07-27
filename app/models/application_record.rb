# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  attr_accessor :current_account

  self.abstract_class = true

  connects_to database: { writing: :primary, reading: :primary }

  def update_with_acc!(account, attributes)
    self.current_account = account
    update!(attributes)
  end

  def record_to_change_history(model, event, message, account)
    model.change_history.create!(event: event, body: message, account: account)
  end
end
