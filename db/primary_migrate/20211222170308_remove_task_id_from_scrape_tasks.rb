# frozen_string_literal: true

class RemoveTaskIdFromScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    remove_column :scrape_tasks, :task_id
  end
end
