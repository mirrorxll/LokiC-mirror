# frozen_string_literal: true

namespace :scrape_task do
  desc 'Attached scrape task'
  task git_links: :environment do
    ScrapeTask.find_each do |t|
      next if t.git_link

      t.create_git_link!
    end
  end

  desc 'Update permissions add git_links'
  task git_link_permissions: :environment do
    Branch.find_by(name: 'scrape_tasks').access_levels.find_each do |t|
      column_data = t.permissions.to_a
      data_index  = column_data.index { |v| v[0] == 'table_locations' }
      next if data_index.nil?

      update_data = column_data.insert(data_index + 1, ['git_links', { 'show' => true, 'edit_form' => true }]).to_h
      t.update(permissions: update_data)
    end
  end
end
