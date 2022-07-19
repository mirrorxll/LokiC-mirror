# frozen_string_literal: true

module FactoidTypes
  class StagingTableAttachingJob < FactoidTypesJob
    def perform(factoid_type_id, account_id, staging_table_name)
      factoid_type = FactoidType.find(factoid_type_id)
      account = Account.find(account_id)
      status = true
      message = 'Success. Staging table attached'

      factoid_type.create_staging_table(name: staging_table_name)
    rescue StandardError, ScriptError => e
      status = nil
      message = e.message
    ensure
      factoid_type.update!(staging_table_attached: status, current_account: account)
      send_to_action_cable(factoid_type, :staging_table, message)
    end
  end
end
