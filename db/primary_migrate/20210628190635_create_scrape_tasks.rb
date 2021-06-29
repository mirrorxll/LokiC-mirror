# frozen_string_literal: true

class CreateScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_tasks do |t|
      t.belongs_to :status
      t.belongs_to :frequency

      # head
      t.string :name
      t.string :note_on_status

      # datasource
      t.string :datasource_url
      t.string :comment_on_datasource

      # scrape
      t.boolean    :scrapable
      t.string     :comment_on_scrapability
      t.string     :instructions_url

      # Evaluation
      t.string :data_set_location
      t.string :data_set_evaluation_doc
      t.string :data_sample_spreadsheet_url

      t.timestamps
    end
  end
end
