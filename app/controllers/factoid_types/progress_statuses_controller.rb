# frozen_string_literal: true

module FactoidTypes
  class ProgressStatusesController < FactoidTypesController
    before_action :find_status

    def change
      @factoid_type.assign_attributes(status: @status, current_account: current_account)
      if @factoid_type.save
        set_status_comment if params[:reason]
      end
    end

    private

    def set_status_comment
      status_comment = @factoid_type.status_comment || @factoid_type.create_status_comment
      status_comment.update!(body: params[:reason], commentator: current_account)
    end

    def find_status
      @status = Status.find(params[:status_id])
    end
  end
end
