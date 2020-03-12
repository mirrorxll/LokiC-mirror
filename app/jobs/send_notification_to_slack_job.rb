class SendNotificationToSlackJob < ApplicationJob
  queue_as :send_notification_to_slack

  def perform(**args)
    client = Slack::Web::Client.new
    puts args
    client.chat_postMessage(args)
  end
end
