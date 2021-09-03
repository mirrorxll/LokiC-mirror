# frozen_string_literal: true

class AddDeadlineToScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :scrape_tasks, :deadline, :date, after: :data_sample_url
  end
end
