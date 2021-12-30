# frozen_string_literal: true

module Api
  module WorkRequests
    class SowsController < ApiController
      def update
        render json: WorkRequest.find(params[:work_request_id]).update!(work_request_params)
      end

      private

      def work_request_params
        params.require(:sow).permit(:default_sow, :link)
      end
    end
  end
end
