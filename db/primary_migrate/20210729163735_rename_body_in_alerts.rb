# frozen_string_literal: true

class RenameBodyInAlerts < ActiveRecord::Migration[6.0]
  def change
    rename_column :alerts, :body, :message
  end
end
