# frozen_string_literal: true

class ChangeColumnsToDataSets < ActiveRecord::Migration[6.0]
  def change
    change_table :data_sets do |t|
      t.remove :evaluator_id,
               :src_release_frequency_id,
               :src_scrape_frequency_id,
               :src_address,
               :src_explaining_data,
               :src_release_frequency_manual,
               :src_scrape_frequency_manual,
               :cron_scraping,
               :evaluation_document,
               :evaluated,
               :evaluated_at,
               :gather_task,
               :scrape_developer

      t.string :sheriffs_doc, after: :location
      t.string :slack_channel, after: :sheriffs_doc
    end
  end
end
