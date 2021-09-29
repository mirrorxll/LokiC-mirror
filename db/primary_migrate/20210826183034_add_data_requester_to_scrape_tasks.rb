# frozen_string_literal: true

class AddDataRequesterToScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    add_column :scrape_tasks, :data_requester, :string, after: :name
  end
end
