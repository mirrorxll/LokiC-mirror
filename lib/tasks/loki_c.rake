# frozen_string_literal: true

desc 'Sync Slack accounts with LokiC'
task slack_accounts: :environment do
  SlackAccountsJob.perform_now
end
