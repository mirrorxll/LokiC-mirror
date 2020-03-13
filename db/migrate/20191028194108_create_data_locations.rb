# frozen_string_literal: true

class CreateDataLocations < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :data_locations do |t|
      t.string    :source_name
      t.string    :data_set_location
      t.string    :data_set_evaluation_document
      t.boolean   :evaluated, default: false
      t.datetime  :evaluated_at
      t.string    :scrape_developer_name
      t.string    :scrape_source
      t.string    :scrape_frequency
      t.string    :data_release_frequency
      t.boolean   :cron_scraping, default: false
      t.string    :scrape_developer_comments, limit: 1000
      t.string    :source_key_explaining_data
      t.string    :gather_task

      t.belongs_to :user
      t.belongs_to :evaluator

      t.timestamps
    end
  end
end
