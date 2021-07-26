# frozen_string_literal: true

class CreateScrapeEvaluationDocs < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_evaluation_docs do |t|
      t.belongs_to :scrape_task

      t.text :body, limit: 16_777_215
      t.timestamps
    end
  end
end
