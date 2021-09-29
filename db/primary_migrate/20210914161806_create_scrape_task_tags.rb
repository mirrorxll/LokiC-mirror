# frozen_string_literal: true

class CreateScrapeTaskTags < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_task_tags do |t|
      t.string :name
      t.timestamps
    end
  end
end
