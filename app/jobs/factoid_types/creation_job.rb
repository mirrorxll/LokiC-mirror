# frozen_string_literal: true

module FactoidTypes
  class CreationJob < FactoidTypesJob
    def perform(iteration_id, account_id)
      iteration = FactoidTypeIteration.find(iteration_id)
      account = Account.find(account_id)

      options = {
        iteration: iteration,
        type: 'article'
      }

      status = true
      message = 'Success. All factoids have been created'

      loop do
        MiniLokiC::FactoidTypeCode[iteration.factoid_type].execute(:creation, options)

        staging_table = iteration.factoid_type.staging_table.name
        break if Table.all_factoids_created_by_iteration?(staging_table)
      end

      true
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      iteration.update!(creation: status, current_account: account)
      send_to_action_cable(iteration.factoid_type, :stories, message)
      SlackIterationNotificationJob.new.perform(iteration.id, 'creation', message)
    end
  end
end
