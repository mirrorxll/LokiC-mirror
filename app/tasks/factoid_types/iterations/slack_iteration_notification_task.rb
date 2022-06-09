# frozen_string_literal: true

module FactoidTypes
  module Iterations
    class SlackIterationNotificationTask < FactoidTypesTask
      def perform(iteration_id, step, raw_message, developer_id = nil)
        iteration        = ArticleTypeIteration.find(iteration_id)
        article_type     = iteration.article_type
        article_type_dev = Account.find_by(id: developer_id) || article_type.developer
        url              = generate_url(article_type)
        progress_step    = step.eql?('developer') ? '' : "| #{step.capitalize}"
        developer_name   = article_type_dev.name
        message          = "*<#{url}|Factoid Type ##{article_type.id}> (#{iteration.name}) #{progress_step}"\
                           " | #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

        ::SlackNotificationTask.new.perform('lokic_article_type_messages', message)
        return if article_type_dev.slack_identifier.nil?

        message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
        ::SlackNotificationTask.new.perform(article_type_dev.slack_identifier, "*[ LokiC ]* #{message}")
      end
    end
  end
end
