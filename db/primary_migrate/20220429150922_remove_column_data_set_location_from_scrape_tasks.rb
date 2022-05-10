# frozen_string_literal: true

class RemoveColumnDataSetLocationFromScrapeTasks < ActiveRecord::Migration[6.0]
  def up
    remove_column :scrape_tasks, :data_set_location
  end

  def down
    add_column :scrape_tasks, :data_set_location, :string, after: :scrapable
  end
end
