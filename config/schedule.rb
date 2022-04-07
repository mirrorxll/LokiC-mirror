# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

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

# CronTab.all.each do |tab|
#   next unless tab.enabled
#
#   every tab.pattern do
#     rake "story_type:execute[#{tab.story_type.id}]"
#   end
# end
