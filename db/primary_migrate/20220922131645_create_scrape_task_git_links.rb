class CreateScrapeTaskGitLinks < ActiveRecord::Migration[6.0]
  def change
    create_table :scrape_task_git_links do |t|
      t.belongs_to :scrape_task
      t.string :link
      t.timestamps
    end
  end
end
