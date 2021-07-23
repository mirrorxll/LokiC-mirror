# frozen_string_literal: true

class AddSubtypeToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :subtype, :string, default: '', after: :alert_id
  end
end
