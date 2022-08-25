# frozen_string_literal: true

class RenameScrapeTasksTasks < ActiveRecord::Migration[6.0]
  def change
    rename_table :scrape_tasks_tasks, :scrape_tasks_multi_tasks
  end
end
