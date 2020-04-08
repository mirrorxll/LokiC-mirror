# frozen_string_literal: true

class SlackAccountsJob < ActiveJob::Base
  queue_as :slack_notifications

  after_perform do
    SlackAccountsJob.set(wait: 1.hour).perform_later
  end

  def perform
    Slack::Web::Client.new.users_list(presence: true)['members'].each do |member|
      account = SlackAccount.find_or_initialize_by(identifier: member['id'])
      account.user_name = member['name']
      account.deleted = member['deleted']

      account.save!
    end
  end
end
