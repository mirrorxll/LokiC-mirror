# frozen_string_literal: true

class AddDefaultValuesToScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    change_column :scrape_tasks, :gather_task, :integer
    change_column_default :scrape_tasks, :datasource_url, ''
    change_column_default :scrape_tasks, :data_set_location, ''
    change_column_default :scrape_tasks, :data_sample_url, ''
  end
end
