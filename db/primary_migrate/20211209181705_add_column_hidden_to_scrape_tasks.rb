# frozen_string_literal: true

class AddColumnHiddenToScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :scrape_tasks, :hidden, :boolean, default: false, after: :name
  end
end
