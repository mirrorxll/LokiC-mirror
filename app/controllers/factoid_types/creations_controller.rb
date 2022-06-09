# frozen_string_literal: true

module FactoidTypes
  class CreationsController < FactoidTypesController # :nodoc:
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration


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
