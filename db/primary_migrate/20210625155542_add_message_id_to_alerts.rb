# frozen_string_literal: true

class AddMessageIdToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_reference :alerts, :message, after: :subtype
  end
end
