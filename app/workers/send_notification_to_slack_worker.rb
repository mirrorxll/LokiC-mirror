class SendNotificationToSlackWorker
  include Sidekiq::Worker

  def perform(channel, text)
    client = Slack::Web::Client.new
    client.chat_postMessage(
      channel: channel,
      text: text,
      as_user: true
    )
  end
end
