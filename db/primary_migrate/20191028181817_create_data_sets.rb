# frozen_string_literal: true

class CreateDataSets < ActiveRecord::Migration[6.0] # :nodoc:
  def change
    create_table :data_sets do |t|
      t.belongs_to :account
      t.belongs_to :evaluator
      t.belongs_to :src_release_frequency
      t.belongs_to :src_scrape_frequency

      t.string    :name
      t.string    :src_address
      t.string    :src_explaining_data
      t.string    :src_release_frequency_manual
      t.string    :src_scrape_frequency_manual
      t.boolean   :cron_scraping, default: false

      t.string    :location
      t.string    :evaluation_document
      t.boolean   :evaluated, default: false
      t.datetime  :evaluated_at

      t.string    :gather_task
      t.string    :scrape_developer
      t.string    :comment, limit: 1000

      t.timestamps
    end
  end
end
