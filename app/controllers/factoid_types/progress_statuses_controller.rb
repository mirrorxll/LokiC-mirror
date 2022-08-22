# frozen_string_literal: true

module FactoidTypes
  class ProgressStatusesController < FactoidTypesController
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
