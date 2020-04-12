# frozen_string_literal: true

class CreateDataSets < ActiveRecord::Migration[5.2] # :nodoc:
  def change
    create_table :data_sets do |t|
      t.belongs_to :account
      t.belongs_to :evaluator

      t.string    :name
      t.string    :source_address
      t.string    :source_explaining_data
      t.string    :source_release_frequency
      t.string    :source_scrape_frequency
      t.boolean   :cron_scraping, default: false

      t.string    :location
      t.string    :evaluation_document
      t.boolean   :evaluated, default: false
      t.datetime  :evaluated_at

      t.string    :scrape_developer
      t.string    :comment, limit: 1000
      t.string    :gather_task
      t.timestamps
    end
  end
end
