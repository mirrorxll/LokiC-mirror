module Api
  module WorkRequests
    class MultiTaskStatusesController < ApiController
      before_action :find_work_request

      def all_deleted
        deleted = @request.multi_tasks.all? { |p| p.status.name.eql?('deleted') }

        render json: { all_deleted: deleted }
      end

      private

      def find_work_request
        @request = WorkRequest.find(params[:id])
      end
    end
  end
end
