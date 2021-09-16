# frozen_string_literal: true

class CreateJoinTableScrapeTasksScrapeTaskTags < ActiveRecord::Migration[6.0]
  def change
    create_join_table :scrape_tasks, :scrape_task_tags do |t|
      t.index %i[scrape_task_id scrape_task_tag_id], name: 'index_on_task_id_tag_id'
      t.index %i[scrape_task_tag_id scrape_task_id], name: 'index_on_tag_id_task_id'
    end
  end
end
