# frozen_string_literal: true

class AddSubtypeIdToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_reference :alerts, :subtype, after: :alert_id
  end
end
