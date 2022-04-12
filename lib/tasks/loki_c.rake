# frozen_string_literal: true

desc 'Sync Slack accounts with LokiC'
task slack_accounts: :environment do
  SlackAccountsJob.new.perform
end
