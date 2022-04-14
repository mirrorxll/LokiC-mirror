# frozen_string_literal: true

class SlackAccountsJob < ApplicationJob
  sidekiq_options queue: :lokic

  def perform(*_args)
    Slack::Web::Client.new.users_list['members'].each do |member|
      account = SlackAccount.find_or_initialize_by(identifier: member['id'])
      account.user_name = member['profile']['real_name']
      account.display_name = member['profile']['display_name']
      account.deleted = member['deleted']

      account.save!
    end
  end
end
