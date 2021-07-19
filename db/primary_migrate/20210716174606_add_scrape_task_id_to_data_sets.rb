# frozen_string_literal: true

class AddScrapeTaskIdToDataSets < ActiveRecord::Migration[6.0]
  def change
    add_reference :data_sets, :scrape_task, after: :deprecated
  end
end
