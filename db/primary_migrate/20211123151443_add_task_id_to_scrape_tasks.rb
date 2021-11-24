# frozen_string_literal: true

class AddTaskIdToScrapeTasks < ActiveRecord::Migration[6.0]
  def change
    add_reference :scrape_tasks, :task, after: :id
  end
end
