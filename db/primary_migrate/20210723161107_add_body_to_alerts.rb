# frozen_string_literal: true

class AddBodyToAlerts < ActiveRecord::Migration[6.0]
  def change
    add_column :alerts, :body, :string, limit: 2000, default: '', after: :subtype
  end
end
