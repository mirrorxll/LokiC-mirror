# frozen_string_literal: true

class SlackAccountsJob < ActiveJob::Base
  queue_as :lokic

  def perform
    Slack::Web::Client.new.users_list['members'].each do |member|
      account = SlackAccount.find_or_initialize_by(identifier: member['id'])
      account.user_name = member['profile']['real_name']
      account.display_name = member['profile']['display_name']
      account.deleted = member['deleted']

      account.save!
      account.touch

      puts member['profile']['display_name']
    end
  end
end
