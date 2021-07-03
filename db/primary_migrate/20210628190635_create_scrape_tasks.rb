# frozen_string_literal: true

class CreateScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_tasks do |t|
      t.belongs_to :creator
      t.belongs_to :scraper
      t.belongs_to :status
      t.belongs_to :frequency

      # head
      t.string :name

      # datasource
      t.string :datasource_url, limit: 1000

      # scrape
      t.boolean :scrapable
      t.string  :gather_task_url

      # evaluation
      t.string :data_set_location
      t.string :data_sample_spreadsheet_url

      t.timestamps
    end

    add_index :scrape_tasks, :name, unique: true
  end
end
