# frozen_string_literal: true

module FactoidTypes
  module Iterations
    class SlackIterationNotificationTask < FactoidTypesTask
      def perform(iteration_id, step, raw_message, developer_id = nil)
        iteration        = FactoidTypeIteration.find(iteration_id)
        factoid_type     = iteration.factoid_type
        factoid_type_dev = Account.find_by(id: developer_id) || factoid_type.developer
        url              = generate_url(factoid_type)
        progress_step    = step.eql?('developer') ? '' : "| #{step.capitalize}"
        developer_name   = factoid_type_dev.name
        message          = "*<#{url}|Factoid Type ##{factoid_type.id}> (#{iteration.name}) #{progress_step}"\
                           " | #{developer_name}*\n#{raw_message}".gsub("\n", "\n>")

        ::SlackNotificationTask.new.perform('lokic_factoid_type_messages', message)
        return if factoid_type_dev.slack_identifier.nil?

        message = message.gsub(/#{Regexp.escape(" | #{developer_name}")}/, '')
        ::SlackNotificationTask.new.perform(factoid_type_dev.slack_identifier, "*[ LokiC ]* #{message}")
      end
    end
  end
end
