# frozen_string_literal: true

module FactoidTypes
  class ProgressStatusesController < FactoidTypesController
    skip_before_action :find_parent_story_type
    skip_before_action :set_story_type_iteration

    before_action :find_status

    def change
      @factoid_type.update!(status: @status, current_account: current_account)
    end

    private

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
