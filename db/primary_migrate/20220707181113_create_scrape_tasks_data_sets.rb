# frozen_string_literal: true

class CreateScrapeTasksDataSets < ActiveRecord::Migration[6.0]
  def change
    create_join_table :scrape_tasks, :data_sets do |t|
      t.index %i[scrape_task_id data_set_id], unique: true, name: 'index_on_scrape_task_data_set'
      t.index %i[data_set_id scrape_task_id], unique: true, name: 'index_on_data_set_scrape_task'
    end
  end
end
