# frozen_string_literal: true

namespace :scrape_task do
  desc "Attached scrape task"
  task git_links: :environment do
    ScrapeTask.find_each do |t|
      next if t.git_link

      t.create_git_link!
    end
  end
end
