# frozen_string_literal: true

module FactoidTypes
  class CreationsController < FactoidTypesController # :nodoc:
     def execute
      @iteration.update!(creation: false, current_account: current_account)
      CreationJob.perform_async(@iteration.id, current_account.id)
    end

    def purge
      @iteration.update!(purge_creation: true, current_account: current_account)
      PurgeCreationJob.perform_async(@iteration.id, current_account.id)
    end
  end
end
