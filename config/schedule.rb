# frozen_string_literal: true

require './' + File.dirname(__FILE__) + '/environment.rb'

every '0 0 * * *' do
  rake 'slack_accounts'
end

every '0 0 * * *' do
  rake 'story_type:clients_pubs_tags_sections'
  rake 'story_type:photo_buckets'
  rake 'story_type:opportunities'
end

every '0 9 * * *' do
  rake 'story_type:reminder'
  rake 'task:reminder'
end

every '0 9,12 * * *' do
  rake 'task:confirm_receipts'
end

every '0 * * * *' do
  rake 'story_type:check_has_updates_revise'
end

every '0 */2 * * *' do
  rake 'scrape_task:schemes_tables'
end

CronTab.all.each do |tab|
  next unless tab.enabled

  every tab.pattern do
    rake "story_type:execute[#{tab.story_type.id}]"
  end
end
