# frozen_string_literal: true

require './' + File.dirname(__FILE__) + '/environment.rb'

every '0 0 * * *' do
  rake 'slack_accounts'
end

every '0 0 * * *' do
  rake 'clients_pubs_tags_sections'
  rake 'photo_buckets'
  rake 'opportunities'
end

every '0 9 * * *' do
  rake 'story_type:reminder'
  rake 'task:reminder'
  rake 'topics:update_topics'
end

every '0 9,12 * * *' do
  rake 'task:confirm_receipts'
end

every '0 * * * *' do
  rake 'check_has_updates_revise'
end

every '0 5,10,15,20 * * *' do
  rake 'scrape_task:schemes_tables'
end

CronTab.all.each do |tab|
  next unless tab.enabled

  every tab.pattern do
    rake "story_type:iteration:execute story_type_id=#{tab.story_type.id}"
  end
end
