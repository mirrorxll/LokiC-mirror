# frozen_string_literal: true

class AddStateIdToScrapeTask < ActiveRecord::Migration[6.0]
  def change
    add_reference :scrape_tasks, :state, after: :frequency_id
  end
end
