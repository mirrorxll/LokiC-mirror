# frozen_string_literal: true

class CreateJoinTableScrapeTasksTasks < ActiveRecord::Migration[6.0]
  def change
    create_join_table :scrape_tasks, :tasks do |t|
      t.index %i[scrape_task_id task_id], name: 'index_on_scrape_task_id_task_id', unique: true
      t.index %i[task_id scrape_task_id], name: 'index_on_task_id_scrape_task_id', unique: true
    end
  end
end
