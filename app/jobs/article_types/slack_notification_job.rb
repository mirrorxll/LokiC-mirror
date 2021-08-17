# frozen_string_literal: true

module ArticleTypes
  class SlackNotificationJob < ArticleTypeJob
    def perform(article_type, iteration, step, raw_message, developer = nil)
      article_type_dev = developer || article_type.developer

      url = generate_url(article_type)
      progress_step = step.eql?('developer') ? '' : "| #{step.capitalize}"
      developer_name = article_type_dev.name
      message = "*<#{url}|Article Type ##{article_type.id}> (#{iteration.name}) #{progress_step}"\
                " | #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

      ::SlackNotificationJob.perform_now(slack_channel, message)
      return if article_type_dev.slack_identifier.nil?

      message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
      ::SlackNotificationJob.perform_now(article_type_dev.slack_identifier, "*[ LokiC ]* #{message}")
    end

    private

    def slack_channel
      Rails.env.production? ? 'lokic_article_type_messages' : 'hle_lokic_development_messages'
    end
  end
end
