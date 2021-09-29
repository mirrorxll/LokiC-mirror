# frozen_string_literal: true

class ChangeScrapableInScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :scrape_tasks, :scrapable, :integer, limit: 1, default: -1
  end
end
